module evael.renderer.graphics_command;

public
{
	import evael.renderer.graphics_buffer;
	import evael.renderer.graphics_pipeline;
	import evael.renderer.enums;

	import evael.utils.color;
	import evael.graphics.texture;
}

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
	 * Renders primitives.
	 * Params:
	 * 		first : starting index in the enabled arrays
	 * 		count :  number of indices to be rendered
	 */
	@nogc
	public void draw(in int first, in int count) const nothrow;

	/**
	 * Renders indexed primitives.
	 * Params:
	 * 		count : number of elements to be rendered
	 * 		type : the type of the values in indices
     *      indices : pointer to the location where the indices are stored
	 */
	@nogc
	public void drawIndexed(in int count, in IndexBufferType type, in void* indices) const nothrow;


	/**
	 * Binds a named texture to a texturing target.
	 * Params:
	 *		texture : texture
	 */
	@nogc
	public void setTexture(Texture texture) const nothrow;
	
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