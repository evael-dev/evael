module evael.renderer.texture;

import evael.lib.memory;

import evael.system.asset;

abstract class Texture : NoGCClass, IAsset
{
	/**
	 * Texture constructor.
	 */
	@nogc
	public this()
	{
	}
}