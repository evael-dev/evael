module evael.audio.AL;

debug import dnogc.Utils;

public import derelict.openal.al;

struct al
{
	static string file = __FILE__;
	static int line = __LINE__;

	@nogc
	static auto ref opDispatch(string name, Args...)(Args args) nothrow
	{ 
		debug
		{
			scope (exit)
			{
				immutable uint error = alGetError();

				if (error != AL_NO_ERROR)
				{
					dln(file, ", ", line, " , gl", name, " : ", error);
				}
			}
		}

		return mixin("al" ~ name ~ "(args)");
	}
}
