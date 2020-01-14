module evael.renderer.vk.vk_command;

import evael.renderer.command;

public 
{
	import evael.utils.color;
	import evael.renderer.texture;
}

class VkCommand : Command
{
	/**
	 * VkCommand constructor.
	 */
	@nogc
	public this(Pipeline pipeline)
	{
		super(pipeline);
	}

	/**
	 * VkCommand destructor.
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
	}
}