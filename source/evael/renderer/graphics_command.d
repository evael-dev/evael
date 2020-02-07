module evael.renderer.graphics_command;

public
{
	import evael.renderer.graphics_buffer;
	import evael.renderer.pipeline;
	import evael.renderer.texture;
	import evael.renderer.enums;
}

import evael.utils.color;
import evael.lib.memory;

/**
 * Command is the base class for all the API commands.
 */
abstract class GraphicsCommand : NoGCClass
{
	protected Pipeline m_pipeline;

	protected VertexBuffer m_vertexBuffer;
	protected IndexBuffer m_indexBuffer;

	/**
	 * Command constructor.
	 */
	@nogc
	public this(Pipeline pipeline)
	{
		this.m_pipeline = pipeline;

		this.verifyPipeline();
	}

	/**
	 * Command destructor.
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
	public void clearColor(in Color color = Color.Black) const nothrow;
	
	@nogc
	protected void verifyPipeline() const
	{
		assert(this.m_pipeline.shader !is null);
	}

	/**
	 * Properties.
	 */
	@nogc
	@property nothrow
	{
		public void pipeline(Pipeline value) 
		{
			this.m_pipeline = value;
		}

		public void vertexBuffer(VertexBuffer value)
		{
			this.m_vertexBuffer = value;
		}

		public void indexBuffer(IndexBuffer value)
		{
			this.m_indexBuffer = value;
		}
	}
} 