module evael.system.window;

import std.traits : EnumMembers;
import std.experimental.logger;

public import bindbc.glfw;

import evael.core.game_config : GraphicsSettings;
import evael.system.cursor;

import evael.lib.memory : NoGCClass;
import evael.lib.string : Cstring;

/**
 * Window.
 *
 * High-level interface to GLFWWindow.
 */
class Window : NoGCClass
{
	/// GLFW window handle
	private GLFWwindow* m_glfwWindow;

	/// GLFW cursors
	private GLFWcursor*[Cursor] m_cursors;

	/// Current cursor
	private Cursor m_currentCursor;

	mixin(GLFWCallback!("onWindowClose", "GLFWwindowclosefun"));
	mixin(GLFWCallback!("onWindowSize", "GLFWwindowsizefun"));
	mixin(GLFWCallback!("onCursorPos", "GLFWcursorposfun"));
	mixin(GLFWCallback!("onMouseButton", "GLFWmousebuttonfun"));
	mixin(GLFWCallback!("onScroll", "GLFWscrollfun"));
	mixin(GLFWCallback!("onKey", "GLFWkeyfun"));
	mixin(GLFWCallback!("onChar", "GLFWcharfun"));
	
	/**
	 * Window constructor.
	 * Params:
	 *		title : window title
	 *      settings : window settings
	 */
	@nogc
	public this(in string title, in ref GraphicsSettings graphicsSettings)
	{
		glfwWindowHint(GLFW_RESIZABLE, graphicsSettings.resizable);
		
		this.m_glfwWindow = glfwCreateWindow(graphicsSettings.width, graphicsSettings.height,
			Cstring(title), graphicsSettings.fullscreen ? glfwGetPrimaryMonitor() : null, null);

		/*foreach(cursor; [EnumMembers!(Cursor)])
		{
			this.m_cursors[cursor] = glfwCreateStandardCursor(cursor);
		}

		this.setCursor(Cursor.Arrow);*/
	}

	/**
	 * Window destructor.
	 */
	@nogc
	public ~this()
	{
		foreach (cursor; this.m_cursors.byValue())
		{
			glfwDestroyCursor(cursor);            
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
	 *      cursor: cursor to set
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

	@nogc
	@property nothrow
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
		return "@nogc @property public void " ~ name ~ "(" ~ glfwCallback ~ " cb) { glfwSet" ~ callbackName[2..$] ~ "(this.m_glfwWindow, cb); }";
	}

	enum GLFWCallback = GLFWCallbackImpl;
}