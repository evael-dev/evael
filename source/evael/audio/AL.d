module evael.audio.AL;

debug import dnogc.Utils;

public import derelict.openal.al;

struct al
{
	@nogc
	static auto ref opDispatch(string name, Args...)(Args args) nothrow
	{ 
		debug
		{
			string file = __FILE__;
			int line = __LINE__;

			scope (exit)
			{
				uint error = alGetError();

				if (error != AL_NO_ERROR)
				{
					dln(file, ", ", line, " , gl", name, " : ", error);
				}
			}
		}

		return mixin("al" ~ name ~ "(args)");
	}
}
