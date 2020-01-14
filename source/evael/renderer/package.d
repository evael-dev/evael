module evael.renderer;

public
{
	import std.typecons : Yes, No;

	version(GL_RENDERER)
	{
		import evael.renderer.gl;
	}
	else version(VK_RENDERER)
	{
		import evael.renderer.vk;
	}

	import evael.renderer.blend_state;
	import evael.renderer.depth_state;
	import evael.renderer.enums;
	import evael.renderer.vertex;
}