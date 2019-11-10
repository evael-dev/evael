module evael.renderer.gl.gl_command;


public 
{
	import evael.renderer.graphics_command;
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
	public override void draw(in int first, in int count) const nothrow
	{
		this.prepareDraw();

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
	public override void drawIndexed(in int count, in IndexBufferType type, in void* indices) const nothrow
	{
		this.prepareDraw();

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
	private void prepareDraw() const nothrow
	{
		gl.UseProgram(this.m_pipeline.shader.programId);
		gl.BindBuffer(this.m_vertexBuffer.type, this.m_vertexBuffer.id);

		/*enum size = cast(GLint) T.sizeof;
		debug 
		{
			import std.stdio;
			writeln("lol");
		}		
		foreach (i, member; __traits(allMembers, T))
		{
			static if (member == "opAssign")
			{
				continue;
			}
			else
			{
				enum UDAs = __traits(getAttributes, mixin(T.stringof ~ "." ~ member));

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

					version(GLDebug) 
					{
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
					static assert(false, "UDA defined member " ~ T.stringof ~ "." ~ member ~ " but is not of the good type.");
				}
			}
		}*/
	}
}