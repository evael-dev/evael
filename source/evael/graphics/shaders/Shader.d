module evael.graphics.shaders.Shader;

import std.experimental.logger : errorf;
import std.exception : enforce;
import std.string : format, toStringz;

import evael.graphics.GL;

import evael.system.Asset;

import evael.utils.Functions;

/**
 * Shader.
 */
class Shader : IAsset
{
	private uint m_programID, m_vertexID, m_fragmentID, m_geometryID;

	/// Shader name
	private string m_name;

	/// Shader uniforms locations
	public int viewMatrix;
    public int modelMatrix;
    public int projectionMatrix;

	/**
	 * Shader constructor.
	 */
    public this(in uint programID, in uint vertexID, in uint fragmentID, in bool linked = true, in uint geometryID = 0)
    {
		this.m_programID = programID;
        this.m_vertexID = vertexID;
        this.m_fragmentID = fragmentID;
		this.m_geometryID = geometryID;

		this.viewMatrix = this.getUniformLocation("view");
		this.modelMatrix = this.getUniformLocation("model");
        this.projectionMatrix = this.getUniformLocation("projection");
    }

	public this(Shader shader)
	{
		this(shader.programID, shader.vertexID, shader.fragmentID, true, shader.geometryID);
	}

	@nogc
	public void dispose() const
	{
		gl.DeleteShader(this.m_vertexID);
		gl.DeleteShader(this.m_fragmentID);

		if (this.m_geometryID)
		{
			gl.DeleteShader(this.m_geometryID);
		}
	}

	public void link()
	{
		gl.LinkProgram(this.m_programID);

		int linkStatus = 0;
		gl.GetProgramiv(this.m_programID, GL_LINK_STATUS, &linkStatus);

		if (linkStatus != 1)
		{
			gl.GetProgramiv(this.m_programID, GL_INFO_LOG_LENGTH, &linkStatus);

			char[] errors = new char[linkStatus];

			gl.GetProgramInfoLog(this.m_programID, linkStatus, &linkStatus, errors.ptr);

			throw new Exception("Cant link shader %s :\n %s".format(this.m_name, errors));
		}
	}

	/**
	 * Returns location of an uniform variable.
	 * Params:
	 *		uniformName : uniform variable to retrieve
	 */
	protected int getUniformLocation(in string uniformName)
	{
		return gl.GetUniformLocation(this.m_programID, uniformName.toStringz());
	}
	
	/**
	 * Loads a shader.
	 * Params:
	 *		shaderName : shader to load
	 */
    public static Shader load(in string shaderName, in bool linkProgram = true)
    {
		import evael.utils.Config;

		immutable string path = Config.Paths.shaders!string ~ shaderName;

		immutable uint programId = gl.CreateProgram();

		immutable vertexShaderId = createShader(programId, path ~ ".vert", ShaderType.Vertex);
		immutable fragmentShaderId = createShader(programId, path ~ ".frag", ShaderType.Fragment);
		immutable geometryShaderId = createShader(programId, path ~ ".geom", ShaderType.Geometry);

		if (linkProgram)
		{
			gl.LinkProgram(programId);
		}

		auto shader = new Shader(programId, vertexShaderId, fragmentShaderId, linkProgram, geometryShaderId);
		shader.name = shaderName;

		return shader;
    }

	/**
	 * Generates and compiles a shader
	 * Params:
	 *		program : program ID
	 * 		fileName : shader to compile
	 * 		type : shader type(VS, FG, GS)
	 */
    static uint createShader(in uint program, in string fileName, in uint type) 
    {
		import std.file;

		if (!exists(fileName))
		{
			errorf("Shader not found: %s", fileName);
			return -1;
		}

        immutable uint shader = gl.CreateShader(type);

        immutable string sourceCode = readText(fileName);

        enforce(sourceCode.length, "Shader %s is empty".format(fileName));

		char* source = cast(char*)sourceCode.ptr;

		// Shader compilation
		gl.ShaderSource(shader, 1, &source, [cast(int)sourceCode.length].ptr);
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

			throw new Exception("Shader %s cant be compiled :\n %s".format(fileName, errors));
		}

		gl.AttachShader(program, shader);

		return shader;
    }

	/**
	 * Properties
	 */
	@nogc
    @property nothrow
	{
		public uint programID() const
		{
			return this.m_programID;
		}

		public uint vertexID() const
		{
			return this.m_vertexID;
		}

		public uint fragmentID() const
		{
			return this.m_fragmentID;
		}

		public uint geometryID() const
		{
			return this.m_geometryID;
		}

		public void name(in string value)
		{
			this.m_name = value;
		}
	}
}