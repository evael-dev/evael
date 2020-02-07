module evael.renderer.gl.gl_wrapper;

public import bindbc.opengl;

struct gl
{
	@nogc
	static auto ref opDispatch(string name, Args...)(Args args, string file = __FILE__, int line = __LINE__) nothrow
	{ 
		debug
		{
			scope (exit)
			{
				immutable uint glError = glGetError();

				if (glError != GL_NO_ERROR)
				{
					import std.conv : to;
                	assert(false, "gl" ~ name ~ ": " ~ glError.to!string());
				}
			}
		}

		return mixin("gl" ~ name ~ "(args)");
	}
}