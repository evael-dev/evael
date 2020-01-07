module evael.renderer.gl.gl_shader;

import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.shader;
import evael.renderer.enums.shader_type;

import evael.lib.memory;

public
{
	import evael.renderer.shader : ShaderAttribute;
}

class GLShader : Shader
{
	private uint m_programId;
	private uint m_vertexShaderId;
	private uint m_fragmentShaderId;
	private uint m_geometryShaderId;

	/**
	 * GLShader constructor.
	 */
	@nogc
	public this(in uint programId, in uint vertexShaderId, in uint fragmentShaderId)
	{
		super();

		this.m_programId = programId;
		this.m_vertexShaderId = vertexShaderId;
		this.m_fragmentShaderId = fragmentShaderId;
	}

	/**
	 * GLShader destructor.
	 */
	@nogc
	public ~this()
	{
		this.dispose();
	}

	// TODO: remove this when IAsset is cleaned.
	@nogc
	public void dispose()
	{
		gl.DeleteShader(this.m_vertexShaderId);
		gl.DeleteShader(this.m_fragmentShaderId);

		if (this.m_geometryShaderId)
		{
			gl.DeleteShader(this.m_geometryShaderId);
		}
	}

	/**
	 * Returns location of an uniform variable.
	 * Params:
	 *		uniformName : uniform variable to retrieve
	 */
	@nogc
	public int getUniformLocation(in string uniformName) const
	{
		return gl.GetUniformLocation(this.m_programId, cast(char*) uniformName.ptr);
	}

	/**
	 * Loads a shader from file.
	 * Params:
	 *		fileName : shader to load
	 */
	public static GLShader load(in string fileName)
	{
		import std.file : readText;

		return GLShader.load(readText(fileName ~ ".vert"), readText(fileName ~ ".frag"));
	}


	/**
	 * Loads a shader from source.
	 * Params:
	 *		vs : vertex shader
	 *		fs : fragment shader
	 */
	public static GLShader load(in string vs, in string fs)
	{
		immutable uint programId = gl.CreateProgram();
		
		immutable uint vertexShaderId = GLShader.compileShader(vs, ShaderType.Vertex);
		immutable uint fragmentShaderId = GLShader.compileShader(fs, ShaderType.Fragment);

		gl.AttachShader(programId, vertexShaderId);
		gl.AttachShader(programId, fragmentShaderId);

		gl.LinkProgram(programId);

		auto shader = MemoryHelper.create!GLShader(programId, vertexShaderId, fragmentShaderId);

		return shader;
	}

	/**
	 * Compiles a shader from a source.
	 * Params:
	 *		type : shader type
	 */
	private static uint compileShader(in string sourceCode, in ShaderType type)
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

	@nogc
	@property nothrow
	{
		public uint programId() const
		{
			return this.m_programId;
		}
	}
}

