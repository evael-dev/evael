module evael.system.AssetLoader;
					  
debug import std.experimental.logger;

import evael.system.Asset;

import evael.graphics.shaders.Shader;

import evael.utils.Singleton;

/**
 * AssetLoader
 */
class AssetLoader
{	
	mixin Singleton!();

	private IAsset[string] m_assets;

	/**
	 * AssetLoader constructor.
	 */
	@nogc @safe
	private this() pure nothrow
	{

	}

	/**
	 * AssetLoader destructor.
	 */
	public void dispose()
	{
		foreach (resource; this.m_assets.byValue())
		{
			resource.dispose();
		}
	}

	/**
	 * Loads an asset.
	 * Params:
     *		fileName : asset to load
	 *      params : variadic params
	 */
	public T load(T, Params...)(in string fileName, Params params)
	{
		import std.conv : to;
		import std.path : baseName;

		immutable shortName = baseName(fileName);

		if (shortName in this.m_assets)
		{
			return cast(T) this.m_assets[shortName];
		}
		else
		{
			debug infof("Loading asset: %s", fileName);
			
			IAsset asset;

			static if (params.length)
			{
				asset = T.load(fileName, params[0]);
			}
			else
			{
				asset = T.load(fileName);
			}

			this.m_assets[shortName] = asset;

			return cast(T) asset;
		}
	}

	/**
	 * Returns all assets of type T.
	 */
	@safe
	public T[] getByType(T)() pure nothrow
	{
		import std.algorithm;
		import std.array;

		return this.m_assets.byValue().filter!(r => (cast(T) r) !is null ).map!(e => cast(T) e).array();
	}
}