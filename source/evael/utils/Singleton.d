module evael.utils.Singleton;

/**
 * Singleton.
 */
template Singleton()
{
	private static bool instantiated;

	private __gshared static typeof(this) instance;
 
	public static typeof(this) getInstance()
	{
		if(!instantiated)
		{
			synchronized(typeof(this).classinfo)
			{
				if(!instance)
				{
					instance = new typeof(this)();
				}
 
				instantiated = true;
			}
		}
 
		return instance;
	}

	public static void dispose()
	{
		if(instantiated) 
		{
			destroy(instance);
			instance = null;
		}
	}
}