module evael.renderer.device;

import evael.lib.memory.no_gc_class;

public 
{
	import evael.renderer.buffer;
	import evael.renderer.command;
	import evael.renderer.shader;
	import evael.renderer.texture;

	import evael.renderer.enums.buffer_type;

	import evael.utils.color;
}

abstract class Device : NoGCClass
{
	/**
	 * Device constructor.
	 */
	@nogc
	public this()
	{
	}

	/**
	 * Device destructor.
	 */
	@nogc
	public ~this()
	{

	}

	@nogc
	public abstract void beginFrame(in Color color = Color.Blue);

	@nogc
	public abstract void endFrame();
} 