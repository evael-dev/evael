module evael.renderer.vk.vk_wrapper;

public import erupted;

struct vk
{
	@nogc
	static auto ref opDispatch(string name, Args...)(Args args, string file = __FILE__, int line = __LINE__) nothrow
	{ 
		debug
		{
			import dnogc.Utils : dln;

		    auto vkResult = mixin("vk" ~ name ~ "(args)");

            if (vkResult != VK_SUCCESS)
            {
                dln(file, ", ", line, " , gl", name, " : ", vkResult);
                return false;
            }

            return true;
		}
        else 
        {
		    return mixin("vk" ~ name ~ "(args)");
        }
	}
}