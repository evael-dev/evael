module evael.renderer.gl.gl_command;

import evael.lib.containers.array;

import evael.graphics.gl;
import evael.renderer.graphics_command;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;

public 
{
	import evael.utils.color;
}

class GLCommand : GraphicsCommand
{
	private GLShader m_shader;

    /**
	 * GLCommand constructor.
	 */
	@nogc
	public this(GraphicsPipeline pipeline)
	{
		super(pipeline);

		this.m_shader = cast(GLShader) pipeline.shader;
	}

	/**
	 * GLCommand destructor.
	 */
	@nogc
	public ~this()
	{

	}

    /**
	 * Specifies clear values for the color buffers.
	 * Params:
	 *		color : clear color
	 */
	@nogc
	public override void clearColor(in Color color = Color.Black) const nothrow
	{
		auto colorf = color.asFloat();

		gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		gl.ClearColor(colorf[0], colorf[1], colorf[2], 1.0f); 
	}

    /**
	 * Renders primitives.
	 * Params:
	 * 		first : starting index in the enabled arrays
	 * 		count : number of indices to be rendered
	 */
	@nogc
	public void draw(T)(in int first, in int count) nothrow
	{
		this.prepareDraw!T();

		gl.DrawArrays(GL_TRIANGLES, first, count);

		this.postDraw();
	}
    
	/**
	 * Renders indexed primitives.
	 * Params:
	 * 		count : number of elements to be rendered
	 * 		type : the type of the values in indices
     *      indices : pointer to the location where the indices are stored
	 */
	@nogc
	public void drawIndexed(T)(in int count, in IndexBufferType type, in void* indices) const nothrow
	{
		this.prepareDraw!T();

		gl.DrawElements(this.m_pipeline.primitiveType, count, type, indices);
	}

	/**
	 * Sets a specific shader uniform variable.
	 * Params:
	 *		param : param name
	 *		value : value to set
	 */
	@nogc
	@property
	public void setShaderParam(T)(in string param, T value)
	{
		static bool initialized = false;
		static int location;

		if (!initialized)
		{
        	location = gl.GetUniformLocation(this.m_shader.programId, cast(char*) param);
			initialized = true;
		}

  		static if ( is(T == int))
        {
            gl.Uniform1i(location, value);
        }
        else
        {
            static assert(false, "Invalid uniform type: " ~ typeof(T));
        }
	}

	/**
	 * Prepares states for the next drawing operation.
	 **/
	@nogc
	private void prepareDraw(T, string file = __FILE__, int line = __LINE__)() nothrow
	{
		gl.BindBuffer(this.m_vertexBuffer.type, this.m_vertexBuffer.id);

		gl.UseProgram(this.m_shader.programId);
		
		this.setBlending();
		this.setTexture();
		this.setVertexAttributes!(T, file, line)();

		gl.BindBuffer(this.m_vertexBuffer.type, 0);
	}
	
	/**
	 * Cleans states for the next drawing operation.
	 */
	@nogc
	private void postDraw() const nothrow
	{
		if (this.m_pipeline.texture !is null)
		{
			gl.BindTexture(GL_TEXTURE_2D, 0);
		}

		if (this.m_pipeline.blendState.enabled)
		{
			gl.Disable(GL_BLEND);
		}
	}

	/**
	 * Sets blending.
	 */
	@nogc
	private void setBlending() const nothrow
	{
		if (!this.m_pipeline.blendState.enabled)
		{
			return;
		}

		gl.Enable(GL_BLEND);
		gl.BlendFuncSeparate(
			GLEnumConverter.blendFactor(this.m_pipeline.blendState.sourceRGB),
			GLEnumConverter.blendFactor(this.m_pipeline.blendState.destinationRGB),
			GLEnumConverter.blendFactor(this.m_pipeline.blendState.sourceAlpha),
			GLEnumConverter.blendFactor(this.m_pipeline.blendState.destinationAlpha)
		);

		gl.BlendEquationSeparate(
			GLEnumConverter.blendFunction(this.m_pipeline.blendState.colorFunction),
			GLEnumConverter.blendFunction(this.m_pipeline.blendState.alphaFunction)
		);
	}

	/**
	 * Sets texturing.
	 */
	@nogc
	private void setTexture() const nothrow
	{
		if (this.m_pipeline.texture is null)
		{
			return;
		}

		gl.BindTexture(GL_TEXTURE_2D, (cast(GLTexture) this.m_pipeline.texture).id);
	}

	/**
	 * Sets vertex attributes.
	 */
	@nogc
	private void setVertexAttributes(T, string file = __FILE__, int line = __LINE__)() const nothrow
	{
		enum size = cast(GLint) T.sizeof;

		foreach (i, member; __traits(allMembers, T))
		{
			enum UDAs = __traits(getAttributes, __traits(getMember, T, member));

			static assert(UDAs.length > 0, "You need to specify UDA for member " ~ T.stringof ~ "." ~ member);

			enum shaderAttribute = UDAs[0];

			static if(is(typeof(shaderAttribute) : ShaderAttribute))
			{
				enum offset = __traits(getMember, T, member).offsetof;

				enum glBufferType = GLEnumConverter.attributeType(shaderAttribute.type);

				gl.EnableVertexAttribArray(shaderAttribute.layoutIndex);
				gl.VertexAttribPointer(
					shaderAttribute.layoutIndex, 
					shaderAttribute.size, 
					glBufferType,  
					shaderAttribute.normalized, 
					size, cast(void*) offset
				);

				version(GL_DEBUG) 
				{
					import std.string : format;
					pragma(msg, "%s:%d : gl.VertexAttribPointer(%d, %d, %d, %d, %d, %d);".format(file, line, shaderAttribute.layoutIndex,
						shaderAttribute.size, 
						shaderAttribute.type, 
						shaderAttribute.normalized, 
						size, offset
					));
				}
			}
			else 
			{
				static assert(false, "UDA defined for member " ~ T.stringof ~ "." ~ member ~ " but is not a valid ShaderAttribute.");
			}
		}
	}
}