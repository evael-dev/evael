module evael.renderer.gl.gl_command;

import evael.renderer.graphics_command;

public 
{
	import evael.utils.color;
	import evael.graphics.texture;
	import evael.renderer.shader;
}

import evael.graphics.gl;

class GLCommand : GraphicsCommand
{
    /**
	 * GLCommand constructor.
	 */
	@nogc
	public this()
	{
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
	public void draw(T)(in int first, in int count) const nothrow
	{
		this.prepareDraw!T();

		gl.DrawArrays(this.m_pipeline.primitiveType, first, count);
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
	 * Binds a named texture to a texturing target.
	 * Params:
	 *		texture : texture
	 */
	@nogc
	public override void setTexture(Texture texture) const nothrow
    {
		gl.BindTexture(GL_TEXTURE_2D, texture.id);
		// TODO: texture
		// gl.Uniform1i
    }

	@nogc
	private void prepareDraw(T, string file = __FILE__, int line = __LINE__)() const nothrow
	{
		gl.UseProgram(this.m_pipeline.shader.programId);
		gl.BindBuffer(this.m_vertexBuffer.type, this.m_vertexBuffer.id);

		enum size = cast(GLint) T.sizeof;

		foreach (i, member; __traits(allMembers, T))
		{
			enum UDAs = __traits(getAttributes, __traits(getMember, T, member));

			static assert(UDAs.length > 0, "You need to specify UDA for member " ~ T.stringof ~ "." ~ member);

			enum shaderAttribute = UDAs[0];

			static if(is(typeof(shaderAttribute) : ShaderAttribute))
			{
				enum offset = __traits(getMember, T, member).offsetof;

				gl.EnableVertexAttribArray(shaderAttribute.layoutIndex);
				gl.VertexAttribPointer(
					shaderAttribute.layoutIndex, 
					shaderAttribute.size, 
					shaderAttribute.type,  
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