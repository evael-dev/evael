module evael.graphics.gui.core.input_handler;

import bindbc.nuklear;
import bindbc.glfw;

import evael.system.input;
import evael.utils.math;

/**
 * InputHandler.
 * Nuklear input handler.
 */
class InputHandler
{
	private GLFWwindow* m_window;

	private nk_context* m_nuklearContext;

	/// Text input
	private uint[256] m_text;
	private int m_textLength;

	/// Last button click timer
	private double m_lastButtonClick;

	// Double click
	private int m_isDoubleClickDown;
	private vec2 m_doubleClickPos;

	@nogc
	public this(GLFWwindow* window, nk_context* nuklearContext) nothrow
	{
		this.m_window = window;
		this.m_nuklearContext = nuklearContext;

		this.m_lastButtonClick = 0;
		this.m_isDoubleClickDown = nk_false;
		this.m_doubleClickPos = vec2(0, 0);
	}

	public void dispose()
	{

	}
	
	public void prepareNewFrame()
	{
		nk_input_begin(this.m_nuklearContext);
		for (int i = 0; i < this.m_textLength; i++)
		{
			nk_input_unicode(this.m_nuklearContext, this.m_text[i]);
		}

		/* optional grabbing behavior */
		if (this.m_nuklearContext.input.mouse.grab)
		{
			glfwSetInputMode(this.m_window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
		}
		else if (this.m_nuklearContext.input.mouse.ungrab)
		{
			glfwSetInputMode(this.m_window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
		}

		nk_input_key(this.m_nuklearContext, NK_KEY_DEL, glfwGetKey(this.m_window, GLFW_KEY_DELETE) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_ENTER, glfwGetKey(this.m_window, GLFW_KEY_ENTER) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_TAB, glfwGetKey(this.m_window, GLFW_KEY_TAB) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_BACKSPACE, glfwGetKey(this.m_window, GLFW_KEY_BACKSPACE) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_UP, glfwGetKey(this.m_window, GLFW_KEY_UP) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_DOWN, glfwGetKey(this.m_window, GLFW_KEY_DOWN) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_START, glfwGetKey(this.m_window, GLFW_KEY_HOME) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_END, glfwGetKey(this.m_window, GLFW_KEY_END) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_SCROLL_START, glfwGetKey(this.m_window, GLFW_KEY_HOME) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_SCROLL_END, glfwGetKey(this.m_window, GLFW_KEY_END) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_SCROLL_DOWN, glfwGetKey(this.m_window, GLFW_KEY_PAGE_DOWN) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_SCROLL_UP, glfwGetKey(this.m_window, GLFW_KEY_PAGE_UP) == GLFW_PRESS);
		nk_input_key(this.m_nuklearContext, NK_KEY_SHIFT, 
			glfwGetKey(this.m_window, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS || glfwGetKey(this.m_window, GLFW_KEY_RIGHT_SHIFT) == GLFW_PRESS);

		if (glfwGetKey(this.m_window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS || glfwGetKey(this.m_window, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS) 
		{
			nk_input_key(this.m_nuklearContext, NK_KEY_COPY, glfwGetKey(this.m_window, GLFW_KEY_C) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_PASTE, glfwGetKey(this.m_window, GLFW_KEY_V) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_CUT, glfwGetKey(this.m_window, GLFW_KEY_X) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_UNDO, glfwGetKey(this.m_window, GLFW_KEY_Z) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_REDO, glfwGetKey(this.m_window, GLFW_KEY_R) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_WORD_LEFT, glfwGetKey(this.m_window, GLFW_KEY_LEFT) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_WORD_RIGHT, glfwGetKey(this.m_window, GLFW_KEY_RIGHT) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_LINE_START, glfwGetKey(this.m_window, GLFW_KEY_B) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_TEXT_LINE_END, glfwGetKey(this.m_window, GLFW_KEY_E) == GLFW_PRESS);
		} 
		else 
		{
			nk_input_key(this.m_nuklearContext, NK_KEY_LEFT, glfwGetKey(this.m_window, GLFW_KEY_LEFT) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_RIGHT, glfwGetKey(this.m_window, GLFW_KEY_RIGHT) == GLFW_PRESS);
			nk_input_key(this.m_nuklearContext, NK_KEY_COPY, 0);
			nk_input_key(this.m_nuklearContext, NK_KEY_PASTE, 0);
			nk_input_key(this.m_nuklearContext, NK_KEY_CUT, 0);
			nk_input_key(this.m_nuklearContext, NK_KEY_SHIFT, 0);
		}

		double x, y;
		glfwGetCursorPos(this.m_window, &x, &y);
		nk_input_motion(this.m_nuklearContext, cast(int) x, cast(int) y);

		if (this.m_nuklearContext.input.mouse.grabbed) 
		{
			glfwSetCursorPos(this.m_window, this.m_nuklearContext.input.mouse.prev.x, this.m_nuklearContext.input.mouse.prev.y);
			this.m_nuklearContext.input.mouse.pos.x = this.m_nuklearContext.input.mouse.prev.x;
			this.m_nuklearContext.input.mouse.pos.y = this.m_nuklearContext.input.mouse.prev.y;
		}

		nk_input_button(this.m_nuklearContext, NK_BUTTON_LEFT, cast(int) x, cast(int)y, glfwGetMouseButton(this.m_window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS);
		nk_input_button(this.m_nuklearContext, NK_BUTTON_MIDDLE, cast(int) x, cast(int)y, glfwGetMouseButton(this.m_window, GLFW_MOUSE_BUTTON_MIDDLE) == GLFW_PRESS);
		nk_input_button(this.m_nuklearContext, NK_BUTTON_RIGHT, cast(int) x, cast(int)y, glfwGetMouseButton(this.m_window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS);
		nk_input_button(this.m_nuklearContext, NK_BUTTON_DOUBLE, 
			cast(int) this.m_doubleClickPos.x, cast(int) this.m_doubleClickPos.y, this.m_isDoubleClickDown);

		//nk_input_scroll(this.m_nuklearContext, glfw.scroll);
		nk_input_end(this.m_nuklearContext);
		this.m_textLength = 0;
		/*glfw.text_len = 0;
		glfw.scroll = nk_vec2(0,0);*/
	}

	/**
	 * Event called on mouse button click action.
	 * Params:
	 *		mouseButton : clicked mouse button
	 *		position : mouse position
	 */
	public void onMouseClick(in MouseButton mouseButton, in ref vec2 position)
	{
		if (mouseButton != MouseButton.Left)
			return;

		immutable double dt = glfwGetTime() - this.m_lastButtonClick;
		
		enum NK_GLFW_DOUBLE_CLICK_LO = 0.02;
		enum NK_GLFW_DOUBLE_CLICK_HI = 0.2;

		if (dt > NK_GLFW_DOUBLE_CLICK_LO && dt < NK_GLFW_DOUBLE_CLICK_HI) 
		{
			this.m_isDoubleClickDown = nk_true;
			this.m_doubleClickPos = position;
		}
		
		this.m_lastButtonClick = glfwGetTime();
	}

	/**
	 * Event called on mouse button release action.
	 * Params:
	 *		mouseButton : released mouse button
	 */
	public void onMouseUp(in MouseButton mouseButton)
	{
		this.m_isDoubleClickDown = nk_false;
	}

	/**
	 * Event called on character input.
	 * Params:
	 *		text : 
	 */
	public void onText(in int text)
	{
		if (this.m_textLength < this.m_text.length)
		{
			this.m_text[this.m_textLength++] = text;
		}
	}
}