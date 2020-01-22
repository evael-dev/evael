module evael.renderer.vk.vk_wrapper;

public import erupted;

struct vk
{
	@nogc
	static auto ref opDispatch(string name, Args...)(Args args, string file = __FILE__, int line = __LINE__) nothrow
	{ 
		debug
		{
		    auto vkResult = mixin("vk" ~ name ~ "(args)");

            if (vkResult != VK_SUCCESS)
            {
				import std.conv : to;
                assert(false, "vk" ~ name ~ ": " ~ vkResult.to!string());
            }

            return true;
		}
        else 
        {
		    return mixin("vk" ~ name ~ "(args)");
        }
	}
}