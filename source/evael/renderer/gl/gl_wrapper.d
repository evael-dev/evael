module evael.renderer.gl.gl_wrapper;

public import bindbc.opengl;

struct gl
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
				immutable uint glError = glGetError();

				if (glError != GL_NO_ERROR)
				{
					dln(file, ", ", line, " , gl", name, " : ", glError);
				}
			}
		}

		return mixin("gl" ~ name ~ "(args)");
	}
}