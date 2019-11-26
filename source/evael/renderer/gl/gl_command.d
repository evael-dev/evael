module evael.renderer.gl.gl_command;

import evael.graphics.gl;
import evael.renderer.graphics_command;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;

public 
{
	import evael.utils.color;
	import evael.renderer.texture;
	import evael.renderer.shader;
}

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

	@nogc
	private void prepareDraw(T, string file = __FILE__, int line = __LINE__)() const nothrow
	{
		gl.BindBuffer(this.m_vertexBuffer.type, this.m_vertexBuffer.id);

		this.applyTexture();
		this.applyVertexAttributes!(T, file, line)();

		gl.BindBuffer(this.m_vertexBuffer.type, 0);
	}
	
	@nogc
	private void postDraw() const nothrow
	{
		if (this.m_pipeline.texture !is null)
		{
			gl.BindTexture(GL_TEXTURE_2D, 0);
		}
	}
	
	@nogc
	private void applyTexture() const nothrow
	{
		if (this.m_pipeline.texture is null)
		{
			return;
		}

		gl.BindTexture(GL_TEXTURE_2D, (cast(GLTexture) this.m_pipeline.texture).id);
	}

	@nogc
	private void applyVertexAttributes(T, string file = __FILE__, int line = __LINE__)() const nothrow
	{
		auto glShader = cast(GLShader) this.m_pipeline.shader;

		gl.UseProgram(glShader.programId);

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