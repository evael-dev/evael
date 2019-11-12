module evael.renderer.gl.gl_graphics_device;

import evael.renderer.graphics_device;
import evael.renderer.gl.gl_command;
import evael.renderer.gl.gl_enum_converter;

import evael.lib.memory;
import evael.lib.containers.array;

class GLGraphicsDevice : GraphicsDevice
{
	private Array!GraphicsBuffer m_buffers;

	/**
	 * GLGraphicsDevice constructor.
	 */
	@nogc
	public this()
	{
	}

	/**
	 * GLGraphicsDevice destructor.
	 */
	@nogc
	public ~this()
	{
		foreach (buffer; this.m_buffers)
			gl.DeleteBuffers(1, &buffer.id);

		this.m_buffers.dispose();
	}
	
	@nogc
	public GLCommand createCommand()
	{
		return MemoryHelper.create!GLCommand();
	}

	/**
	 * Create a buffer object.
	 * Params:
	 *		type : buffer type
	 *		size : buffer object size
	 *		data : data to send
	 */
	@nogc
	public override GraphicsBuffer createBuffer(BufferType type, in ptrdiff_t size = 0, in void* data = null) nothrow
	{		
		auto buffer = this.generateBuffer(type);

		if (size > 0)
			this.allocateBuffer(buffer, size, data);

		return buffer;
	}

	public void lol()
	{
		
	}
	/**
	 * Deletes a buffer object.
	 * Params:
	 *		buffer : buffer
	 */
	@nogc
	public override void deleteBuffer(in GraphicsBuffer bufferToDelete)
	{
		gl.DeleteBuffers(1, &bufferToDelete.id);

		foreach (i, buffer; this.m_buffers)
		{
			if(buffer.id == bufferToDelete.id)
			{
				this.m_buffers.removeAt(i);
				break;
			}
		}
	}

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 buffer : buffer
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public override void updateBuffer(ref GraphicsBuffer buffer, in long offset, in ptrdiff_t size, in void* data) const nothrow
	{
		gl.BindBuffer(buffer.type, buffer.id);

		if (buffer.size == 0)
		{
			this.allocateBuffer(buffer, size, data);
		}
		else 
		{
			assert(offset + size <= buffer.size, "Updating buffer with invalid offset/size.");
			gl.BufferSubData(buffer.type, offset, size, data);
		}
	}

	public override Shader createShader(in string vertexSource, in string fragmentSource) const
	{
		import std.string : format;

		immutable uint programId = gl.CreateProgram();
		
		immutable uint vertexShaderId = this.compileShader(vertexSource, ShaderType.Vertex);
		immutable uint fragmentShaderId = this.compileShader(fragmentSource, ShaderType.Fragment);

		gl.AttachShader(programId, vertexShaderId);
		gl.AttachShader(programId, fragmentShaderId);

		gl.LinkProgram(programId);

		return Shader(programId, vertexShaderId, fragmentShaderId);
	}

	/**
	 * Generates a buffer object.
	 * Params:
	 *		type : buffer object type
	 */
	@nogc
	private GraphicsBuffer generateBuffer(in BufferType type) nothrow
	{
		immutable glBufferType = GLEnumConverter.bufferType(type);

		uint id;
		gl.GenBuffers(1, &id);
		gl.BindBuffer(glBufferType, id);

		GraphicsBuffer buffer = 
		{
			id: id,
			type: glBufferType
		};

		this.m_buffers.insert(buffer);

		return buffer;
	}

	@nogc
	private void allocateBuffer(ref GraphicsBuffer buffer, ptrdiff_t size, in void* data) const nothrow
	{
		gl.BufferData(buffer.type, size, data, GL_DYNAMIC_DRAW);
		buffer.size = size;
	}

	private uint compileShader(in string sourceCode, in ShaderType type) const
	{
		import std.string : format;
		import std.exception : enforce;

        immutable uint shader = gl.CreateShader(GLEnumConverter.shaderType(type));

        assert(sourceCode.length);

		char* source = cast(char*) sourceCode.ptr;

		// Shader compilation
		gl.ShaderSource(shader, 1, &source, [cast(int) sourceCode.length].ptr);
		gl.CompileShader(shader);

		int compilationStatus;
		gl.GetShaderiv(shader, GL_COMPILE_STATUS, &compilationStatus);

		// We check for compilation errors
		if (compilationStatus == false)
		{
			// Compilation failed, we retrieve error logs
			gl.GetShaderiv(shader, GL_INFO_LOG_LENGTH, &compilationStatus);

			char[] errors = new char[compilationStatus];

			gl.GetShaderInfoLog(shader, compilationStatus, &compilationStatus, errors.ptr);

			throw new Exception("Shader %s can't be compiled :\n %s.".format(sourceCode, errors));
		}

		return shader;
	}
} 

debug import dnogc.Utils;
import bindbc.opengl;

struct gl
{
	static string file = __FILE__;
	static int line = __LINE__;

	@nogc
	static auto ref opDispatch(string name, Args...)(Args args) nothrow
	{ 
		debug
		{
			scope (exit)
			{
				immutable uint error = glGetError();

				if (error != GL_NO_ERROR)
				{
					dln(file, ", ", line, " , gl", name, " : ", error);
				}
			}
		}

		return mixin("gl" ~ name ~ "(args)");
	}
}