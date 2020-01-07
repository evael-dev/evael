module evael.renderer.gl.gl_command;

import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;

import evael.renderer.command;
import evael.renderer.resources;

import evael.lib.containers.array;

public 
{
	import evael.utils.color;
}

class GLCommand : Command
{
	private GLShader m_shader;

	/**
	 * GLCommand constructor.
	 */
	@nogc
	public this(Pipeline pipeline)
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
	 * Prepares states for the next drawing operation.
	 **/
	@nogc
	private void prepareDraw(T, string file = __FILE__, int line = __LINE__)() nothrow
	{
		gl.UseProgram(this.m_shader.programId);
		
		this.setDepthState();
		this.setBlendState();
		this.setResources();

		gl.BindBuffer(this.m_vertexBuffer.internalType, this.m_vertexBuffer.id);
		this.setVertexAttributes!(T, file, line)();
	}
	
	/**
	 * Cleans states for the next drawing operation.
	 */
	@nogc
	private void postDraw() nothrow
	{
		foreach (resource; this.m_pipeline.resources)
		{
			resource.clear();
		}

		if (this.m_pipeline.blendState.enabled)
		{
			gl.Disable(GL_BLEND);
		}

		if (this.m_pipeline.depthState.enabled)
		{
			gl.Disable(GL_DEPTH_TEST);
		}

		gl.BindBuffer(this.m_vertexBuffer.internalType, 0);
	}

	/**
	 * Sets depth state.
	 */
	@nogc
	private void setDepthState() const nothrow
	{
		if (!this.m_pipeline.depthState.enabled)
		{
			return;
		}

		gl.Enable(GL_DEPTH_TEST);
		gl.DepthMask(!this.m_pipeline.depthState.readOnly);
	}

	/**
	 * Sets blend state.
	 */
	@nogc
	private void setBlendState() const nothrow
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
	 * Sets resources.
	 */
	@nogc
	private void setResources()	 nothrow
	{
		foreach (resource; this.m_pipeline.resources)
		{
			resource.apply();
		}
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