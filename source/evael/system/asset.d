module evael.system.asset;

import evael.lib.memory : NoGCInterface;

/**
 * Base interface for an asset
 */
interface IAsset : NoGCInterface
{
	public void load()(in string fileName, ...);
}