module evael.renderer.gl.gl_device;

import bindbc.glfw;

import evael.renderer.graphics_device;
import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;
import evael.renderer.gl.gl_context_settings;

import evael.core.game_config : GraphicsSettings;

import evael.lib.image.image;
import evael.lib.memory;
import evael.lib.containers.array;

debug 
{
	import std.experimental.logger;
}

class GLDevice : GraphicsDevice
{
	private uint m_vao;

	/**
	 * GLDevice constructor.
	 */
	@nogc
	public this(in ref GraphicsSettings graphicsSettings, GLFWwindow* window)
	{
		super(graphicsSettings, window);

		this.initialize();
	}

	/**
	 * GLDevice destructor.
	 */
	@nogc
	public ~this()
	{

	}
	
	@nogc
	private void initialize()
	{		
		this.initializeGLFW();
		
		debug infof("OpenGL %s loaded.", loadOpenGL());

		gl.GenVertexArrays(1, &this.m_vao);
		gl.BindVertexArray(this.m_vao);
	}

	@nogc
	private void initializeGLFW()
	{
		immutable contextSettings = GLContextSettings();

		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, contextSettings.ver / 10);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, contextSettings.ver % 10);
		glfwWindowHint(GLFW_OPENGL_PROFILE, contextSettings.profile);
		glfwWindowHint(GLFW_SAMPLES, 4);

		glfwMakeContextCurrent(this.m_window);
		glfwSwapInterval(this.m_graphicsSettings.vsync);
	}

	@nogc
	public override void beginFrame(in Color color = Color.LightGrey)
	{
		auto colorf = color.asFloat();

		gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		gl.ClearColor(colorf[0], colorf[1], colorf[2], 1.0f); 
	}

	@nogc
	public override void endFrame()
	{

	}
} 