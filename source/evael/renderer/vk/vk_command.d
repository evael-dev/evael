module evael.renderer.vk.vk_command;

import evael.renderer.graphics_command;

public 
{
	import evael.utils.color;
	import evael.renderer.texture;
}

class VkCommand : GraphicsCommand
{
    /**
	 * VkCommand constructor.
	 */
	@nogc
	public this()
	{
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
	public void draw(in int first, in int count) const nothrow
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
	public void drawIndexed(in int count, in IndexBufferType type, in void* indices) const nothrow
	{

	}
}