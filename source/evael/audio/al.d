module evael.audio.al;

public import bindbc.openal;

struct al
{
	static string file = __FILE__;
	static int line = __LINE__;

	@nogc
	static auto ref opDispatch(string name, Args...)(Args args) nothrow
	{ 
		debug
		{
			import dnogc.Utils : dln;
			import std.experimental.logger : error;
			scope (exit)
			{
				immutable uint alError = alGetError();

				if (alError != AL_NO_ERROR)
				{
					dln(file, ", ", line, " , al", name, " : ", alError);
				}
			}
		}

		return mixin("al" ~ name ~ "(args)");
	}
}
