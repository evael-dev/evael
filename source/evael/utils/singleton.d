module evael.utils.singleton;

import evael.lib.memory;

/**
 * Singleton.
 */
template Singleton()
{
    private static bool instantiated;

    private __gshared static typeof(this) instance;
 
    @nogc
    public static typeof(this) getInstance()
    {
        if (!instantiated)
        {
            synchronized (typeof(this).classinfo)
            {
                if (!instance)
                {
                    instance = MemoryHelper.create!(typeof(this))();
                }
 
                instantiated = true;
            }
        }
 
        return instance;
    }

    @nogc
    public static void dispose()
    {
        if (instantiated) 
        {
            MemoryHelper.dispose(instance);
            instance = null;
        }
    }
}