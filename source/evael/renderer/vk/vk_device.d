module evael.renderer.vk.vk_device;

import evael.renderer.device;
import evael.renderer.vk.vk_command;

import evael.lib.memory;
import evael.lib.containers.array;

class VkDevice : Device
{
	/**
	 * VkDevice constructor.
	 */
	@nogc
	public this()
	{
	}

	/**
	 * VkDevice destructor.
	 */
	@nogc
	public ~this()
	{

	}
	
	@nogc
	public override void beginFrame(in Color color = Color.LightGrey)
	{

	}

	@nogc
	public override void endFrame()
	{

	}
} 