module evael.system.asset_loader;
                      
debug import std.experimental.logger;

import evael.system.asset;

import evael.utils.singleton;

import evael.lib.memory;

/**
 * AssetLoader
 */
class AssetLoader : NoGCClass
{	
    mixin Singleton!();

    private IAsset[string] m_assets;

    /**
     * AssetLoader constructor.
     */
    @nogc
    private this() nothrow
    {

    }

    /**
     * AssetLoader destructor.
     */
    @nogc
    public ~this()
    {
        foreach (resource; this.m_assets.byValue())
        {
            MemoryHelper.dispose(resource);
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