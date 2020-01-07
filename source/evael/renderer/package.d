module evael.renderer;

public
{
	import std.typecons : Yes, No;

	version(GL_RENDERER)
	{
		import evael.renderer.gl;
	}

	import evael.renderer.blend_state;
	import evael.renderer.depth_state;
	import evael.renderer.enums;
}