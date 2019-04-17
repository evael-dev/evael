module evael.Window.GLContextSettings;

import derelict.glfw3.glfw3;

/**
 * GLContextSettings
 */
struct GLContextSettings 
{
	/**
	 * GLFW_OPENGL_PROFILE specifies which OpenGL profile to create the context for. 
	 * Possible values are one of GLFW_OPENGL_CORE_PROFILE or GLFW_OPENGL_COMPAT_PROFILE, 
	 * or GLFW_OPENGL_ANY_PROFILE to not request a specific profile. 
	 * If requesting an OpenGL version below 3.2, GLFW_OPENGL_ANY_PROFILE must be used. 
	 * If OpenGL ES is requested, this hint is ignored
	 */
	enum Profile
	{
		Default = GLFW_OPENGL_ANY_PROFILE,
		Compatibility = GLFW_OPENGL_COMPAT_PROFILE,
		Core = GLFW_OPENGL_CORE_PROFILE
	}

	enum Version : ubyte
	{
		GL32 = 32,
		GL33 = 33,
		GL40 = 40,
		GL41 = 41,
		GL42 = 42,
		GL43 = 43,
		GL44 = 44,
		GL45 = 45
	}

	enum AntiAliasing : byte
	{
		None = GLFW_DONT_CARE,
		X2 = 2,
		X4 = 4,
		X8 = 8,
		X16 = 16
	}

	public Profile profile = Profile.Core;
	public Version ver = Version.GL33;
	public AntiAliasing antiAliasing = AntiAliasing.None;
}