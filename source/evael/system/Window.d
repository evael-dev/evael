module evael.system.Window;

import std.string : toStringz;
import std.traits : EnumMembers;

public import derelict.glfw3.glfw3;
import derelict.opengl;
import derelict.nanovg.nanovg;

import evael.system.WindowSettings;
import evael.system.GLContextSettings;
import evael.system.Cursor;

/**
 * Window.
 *
 * High-level interface to GLFWWindow.
 */
class Window
{
	/// GLFW window handle
	private GLFWwindow* m_glfwWindow;

	/// GLFW cursors
	private GLFWcursor*[Cursor] m_cursors;

	/// Current cursor
	private Cursor m_currentCursor;

	mixin(GLFWCallback!("WindowClose", "GLFWwindowclosefun"));
	mixin(GLFWCallback!("WindowSize", "GLFWwindowsizefun"));
	mixin(GLFWCallback!("CursorPos", "GLFWcursorposfun"));
	mixin(GLFWCallback!("MouseButton", "GLFWmousebuttonfun"));
	mixin(GLFWCallback!("Scroll", "GLFWscrollfun"));
	mixin(GLFWCallback!("Key", "GLFWkeyfun"));
	mixin(GLFWCallback!("Char", "GLFWcharfun"));

	/**
	 * Window constructor.
	 * Params:
	 *      settings : window settings
	 *      contextSettings : gl settings
	 */
	public this(in ref WindowSettings settings, in ref GLContextSettings contextSettings)
	{
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, contextSettings.ver / 10);
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, contextSettings.ver % 10);
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
		glfwWindowHint(GLFW_RESIZABLE, settings.resizable);
		glfwWindowHint(GLFW_SAMPLES, 4);
		
		this.m_glfwWindow = glfwCreateWindow(settings.resolution.width, settings.resolution.height,
			settings.title.toStringz(), settings.fullscreen ? glfwGetPrimaryMonitor() : null, null);

		glfwMakeContextCurrent(this.m_glfwWindow);
		
		glfwSwapInterval(settings.vsync);
		
		// We have a context now, we can reload gl3
		DerelictGL3.reload();
		DerelictNANOVG.load();

		foreach(cursor; [EnumMembers!(Cursor)])
		{
			this.m_cursors[cursor] = glfwCreateStandardCursor(cursor);
		}

		this.setCursor(Cursor.Arrow);
	}

	/**
	 * Window destructor.
	 */
	public void dispose()
	{
		foreach (cursor; [EnumMembers!(Cursor)])
		{
			glfwDestroyCursor(this.m_cursors[cursor]);            
		}

		glfwDestroyWindow(this.m_glfwWindow);
	}

	/**
	 * Polls window events.
	 */
	@nogc
	public void pollEvents() nothrow
	{
		glfwSwapBuffers(this.m_glfwWindow);
		glfwPollEvents();
	}
	
	/**
	 * Sets window cursor.
	 * Params:
	 *      cursor : cursor to set
	 */
	@nogc
	public void setCursor(in Cursor cursor) nothrow
	{
		if (this.m_currentCursor == cursor)
		{
			return;
		}

		auto cursorPtr = cursor in this.m_cursors;

		if (cursorPtr !is null)
		{
			this.m_currentCursor = cursor;
			glfwSetCursor(this.m_glfwWindow, *cursorPtr);
		}
	}

	/**
	 * Hides cursor.
	 */
	@nogc
	public void hideCursor() nothrow
	{
		glfwSetInputMode(this.m_glfwWindow, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
	}

	@nogc @safe
	@property pure nothrow
	{
		GLFWwindow* glfwWindow() 
		{
			return this.m_glfwWindow;
		}
	}
}

template GLFWCallback(string name, string glfwCallback)
{
	string GLFWCallbackImpl()
	{
		enum callbackName = name ~ "Callback";
		return "public void set" ~ callbackName ~ "(" ~ glfwCallback ~ " cb) { glfwSet" ~ callbackName ~ "(this.m_glfwWindow, cb); }";
	}

	enum GLFWCallback = GLFWCallbackImpl;
}