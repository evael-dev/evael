module evael.renderer.graphics_command;

public
{
	import evael.renderer.graphics_buffer;
	import evael.renderer.graphics_pipeline;
	import evael.renderer.texture;
	import evael.renderer.enums;
}

import evael.utils.color;
import evael.lib.memory;

/**
 * GraphicsCommand is the base class for all the API commands.
 */
abstract class GraphicsCommand : NoGCClass
{
	protected GraphicsPipeline m_pipeline;

	protected GraphicsBuffer m_vertexBuffer;
	protected GraphicsBuffer m_indexBuffer;

	/**
	 * GraphicsCommand constructor.
	 */
	@nogc
	public this()
	{
	}

	/**
	 * GraphicsCommand destructor.
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
	
	/**
	 * Properties.
	 */
	@nogc
	@property nothrow
	{
		public void pipeline(GraphicsPipeline value) 
		{
			this.m_pipeline = value;
		}

		public void vertexBuffer(in ref GraphicsBuffer value)
		{
			this.m_vertexBuffer = value;
		}

		public void indexBuffer(in ref GraphicsBuffer value)
		{
			this.m_indexBuffer = value;
		}
	}
} 