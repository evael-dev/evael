module evael.system.asset;

/**
 * Base interface for an asset
 */
interface IAsset
{
	public void load()(in string fileName, ...);
	public void dispose();
}