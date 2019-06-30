module evael.graphics.gui2.GuiManager;

import core.stdc.string : memcpy, memset;
import core.stdc.stdlib : free, malloc;
import std.stdio;

import bindbc.glfw;
import bindbc.nuklear;

import evael.graphics.gui2.Style;

import evael.graphics.gui2.core.Renderer;
import evael.graphics.gui2.core.InputHandler;

import evael.graphics.gui2.widgets.Window;

import evael.graphics.GraphicsDevice;
import evael.graphics.Texture;

import evael.system.Input : MouseButton;

import evael.utils.Math : vec2;

import dnogc.DynamicArray;

/**
 * GuiManager.
 * Nuklear GLFW implementation.
 */
class GuiManager
{
	private nk_context m_nuklearContext;
	private nk_font_atlas m_fontAtlas;

	private Texture m_fontTexture;

	/// Nuklear renderer
	private Renderer m_renderer;

	/// Nuklear input handler
	private InputHandler m_inputHandler;

	private DynamicArray!Window m_windows;

	public this(GraphicsDevice graphicsDevice, GLFWwindow* window)
	{
		nk_init_default(&this.m_nuklearContext, null);

		this.m_renderer = new Renderer(graphicsDevice, window, &this.m_nuklearContext);
		this.m_inputHandler = new InputHandler(window, &this.m_nuklearContext);
	}

	public void dispose()
	{
		nk_font_atlas_clear(&this.m_fontAtlas);
		nk_free(&this.m_nuklearContext);

		this.m_fontTexture.dispose();
		this.m_windows.dispose();
		this.m_renderer.dispose();
		this.m_inputHandler.dispose();
	}

	public void draw()
	{
		this.m_renderer.prepareNewFrame();
		this.m_inputHandler.prepareNewFrame();

		foreach (window; this.m_windows)
		{
			window.draw();
		}

		this.m_renderer.draw();
	}

	/**
	 * Event called on mouse button click action.
	 * Params:
	 *		position : mouse position
	 *		mouseButton : clicked mouse button
	 */
	public void onMouseClick(in MouseButton mouseButton, in ref vec2 mousePosition)
	{
		this.m_inputHandler.onMouseClick(mouseButton, mousePosition);
	}

	/**
	 * Event called on mouse button release action.
	 * Params:
	 *		position : mouse position
	 *		mouseButton : released mouse button
	 */
	public void onMouseUp(in MouseButton mouseButton)
	{
		this.m_inputHandler.onMouseUp(mouseButton);
	}

	/**
	 * Event called on mouse movement action.
	 * Params:
	 *		position : mouse position
	 */
	public void onMouseMove(in ref vec2 position)
	{	

	}

	/**
	 * Event called on character input.
	 * Params:
	 *		text : 
	 */
	public void onText(in int text)
	{
		this.m_inputHandler.onText(text);
	}

	/**
	 * Event called on key action.
	 * Params:
	 *		key : pressed key
	 */
	public void onKey(in int key)
	{

	}

	public void setFont(in string name, in int size)
	{
		nk_font_atlas_init_default(&this.m_fontAtlas);
		nk_font_atlas_begin(&this.m_fontAtlas);
		nk_font* font = nk_font_atlas_add_from_file(&this.m_fontAtlas, cast(char*) name.ptr, size, null);

		int w, h;
		const(void*) image = nk_font_atlas_bake(&this.m_fontAtlas, &w, &h, NK_FONT_ATLAS_RGBA32);

		this.m_fontTexture = Texture.fromMemory(w, h, image);

		nk_draw_null_texture nullTexture;

		nk_font_atlas_end(&this.m_fontAtlas, nk_handle_id(this.m_fontTexture.id), &nullTexture);
		nk_style_set_font(&this.m_nuklearContext, &font.handle);
	}

	public void setStyle(in ref Style style)
	{
		nk_color[StyleColor.Count] nkColors;

		foreach (i, ref color; style.colors)
		{
			nkColors[i] = nk_color(color.r, color.g, color.b, color.a);
		}

		nk_style_from_table(&this.m_nuklearContext, nkColors.ptr);
	}

	public Window createWindow()
	{
		auto window = new Window();
		window.nuklearContext = &this.m_nuklearContext;

		this.m_windows ~= window;

		return window;
	}

	@nogc @safe
	@property pure nothrow
	{
		public nk_context* context()
		{
			return &this.m_nuklearContext;
		}
	}
}

// extern(C) void nk_gflw3_scroll_callback(GLFWwindow *win, double xoff, double yoff) nothrow
// {
//     glfw.scroll.x += cast (float)xoff;
//     glfw.scroll.y += cast (float)yoff;
// }


// void nk_glfw3_clipboard_paste(nk_handle usr,  nk_text_edit *edit)
// {
//     const(char)* text = glfwGetClipboardString(glfw.win);
//     if (text) nk_textedit_paste(edit, text, nk_strlen(text));
// }

// void nk_glfw3_clipboard_copy(nk_handle usr, const char *text, int len)
// {
//     char *str = null;
//     if (!len) return;
//     str = cast (char*)malloc(cast (size_t)len+1);
//     if (!str) return;
//     memcpy(str, text, cast (size_t)len);
//     str[len] = '\0';
//     glfwSetClipboardString(glfw.win, str);
//     free(str);
// }