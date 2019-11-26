module evael.renderer.gl.gl_graphics_device;

import evael.renderer.graphics_device;
import evael.renderer.gl.gl_command;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;

import evael.lib.image.image;
import evael.lib.memory;
import evael.lib.containers.array;

class GLGraphicsDevice : GraphicsDevice
{
	private Array!GraphicsBuffer m_buffers;

	private uint m_vao;

	/**
	 * GLGraphicsDevice constructor.
	 */
	@nogc
	public this()
	{
		this.initialize();
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
	private void initialize()
	{
		gl.GenVertexArrays(1, &this.m_vao);
		gl.BindVertexArray(this.m_vao);
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
		immutable uint programId = gl.CreateProgram();
		
		immutable uint vertexShaderId = this.compileShader(vertexSource, ShaderType.Vertex);
		immutable uint fragmentShaderId = this.compileShader(fragmentSource, ShaderType.Fragment);

		gl.AttachShader(programId, vertexShaderId);
		gl.AttachShader(programId, fragmentShaderId);

		gl.LinkProgram(programId);

		return MemoryHelper.create!GLShader(programId, vertexShaderId, fragmentShaderId);
	}

	@nogc
	public override Texture createTexture() const
	{
		uint id;
		gl.GenTextures(1, &id);

		return MemoryHelper.create!GLTexture(id);
	}

	public override Texture createTexture(in string name) const
	{
		auto texture = cast(GLTexture) this.createTexture();

		auto image = Image.fromFile(name);

		gl.BindTexture(GL_TEXTURE_2D, texture.id);
		gl.TexImage2D(GL_TEXTURE_2D,
					0,                // Mipmap level (0 being the top level i.e. full size)
					GL_RGBA,          // Internal format
					image.width,       // Width of the texture
					image.height,      // Height of the texture,
					0,                // Border in pixels
					GL_BGRA,          // Data format
					GL_UNSIGNED_BYTE, // Type of texture data
					image.bytes);     // The image data to use for this texture
	
		MemoryHelper.dispose(image);
		
		auto minificationFilter = GL_LINEAR;
		auto magnificationFilter = GL_LINEAR;

		// Anisotropic filter
		float fLargest;
		gl.GetFloatv(0x84FF, &fLargest);
		gl.TexParameterf(GL_TEXTURE_2D, 0x84FE, fLargest);

		// Specify our minification and magnification filters
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minificationFilter);
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magnificationFilter);
	
		// If we're using MipMaps, then we'll generate them here.
		// Note: The glGenerateMipmap call requires OpenGL 3.0 as a minimum.
		if (minificationFilter == GL_LINEAR_MIPMAP_LINEAR   ||
			minificationFilter == GL_LINEAR_MIPMAP_NEAREST  ||
			minificationFilter == GL_NEAREST_MIPMAP_LINEAR  ||
			minificationFilter == GL_NEAREST_MIPMAP_NEAREST)
		{
			gl.GenerateMipmap(GL_TEXTURE_2D);
		}
	
		return texture;
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
			import dnogc.Utils : dln;
			import std.experimental.logger : error;
			scope (exit)
			{
				immutable uint glError = glGetError();

				if (glError != GL_NO_ERROR)
				{
					dln(file, ", ", line, " , gl", name, " : ", glError);
				}
			}
		}

		return mixin("gl" ~ name ~ "(args)");
	}
}