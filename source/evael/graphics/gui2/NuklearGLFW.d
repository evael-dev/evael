module evael.graphics.gui2.NuklearGLFW;

import core.stdc.string : memcpy, memset;
import core.stdc.stdlib : free, malloc;
import std.stdio;

import bindbc.glfw;
public import bindbc.nuklear;

import evael.graphics.GraphicsDevice;
import evael.graphics.GL;
import evael.graphics.Texture;
import evael.graphics.shaders.Shader;
import evael.graphics.Vertex;

import evael.system.AssetLoader;
import evael.system.Input;

import evael.utils;

import std.experimental.logger;

alias NuklearVertex = Vertex2PositionColorTexture;

/**
 * Nuklear GLFW implementation.
 * Based on : https://github.com/vurtun/nuklear/blob/master/demo/glfw_opengl3/
 */
class NuklearGLFW
{
	private GraphicsDevice m_graphicsDevice;

	private GLFWwindow* m_window;

	private nk_context m_nuklearContext;
	private nk_font_atlas m_fontAtlas;
	private nk_draw_null_texture m_nullTexture;

	private Texture m_fontTexture;

	private double m_lastButtonClick;
	private int m_isDoubleClickDown;
	private vec2 m_doubleClickPos;

	private nk_buffer m_commands;

	private NuklearShader m_nuklearShader;

	private uint m_vao, m_vertexBuffer, m_indexBuffer;

	private Size!int m_windowSize, m_frameBufferSize;
	private Size!float m_frameBufferScale;

	private nk_convert_config m_convertConfig;

	private nk_draw_vertex_layout_element[] m_vertexLayout = [
		{ NK_VERTEX_POSITION, NK_FORMAT_FLOAT, (NuklearVertex.position).offsetof },
		{ NK_VERTEX_COLOR, NK_FORMAT_R8G8B8A8, (NuklearVertex.color).offsetof },
		{ NK_VERTEX_TEXCOORD, NK_FORMAT_FLOAT, (NuklearVertex.textureCoordinate).offsetof },
		NK_VERTEX_LAYOUT_END
	];

	public this(GraphicsDevice graphicsDevice, GLFWwindow* window)
	{
		this.m_graphicsDevice = graphicsDevice;
		this.m_window = window;
		this.m_lastButtonClick = 0;
		this.m_isDoubleClickDown = nk_false;
		this.m_doubleClickPos = vec2(0, 0);

		nk_init_default(&this.m_nuklearContext, null);
		nk_buffer_init_default(&this.m_commands);

		this.m_nuklearShader = new NuklearShader(AssetLoader.getInstance().load!(Shader)("gui"));

		this.m_vao = this.m_graphicsDevice.generateVAO();
		this.m_vertexBuffer = this.m_graphicsDevice.generateBuffer(BufferType.VertexBuffer);
		this.m_indexBuffer = this.m_graphicsDevice.generateBuffer(BufferType.IndexBuffer);

		this.m_graphicsDevice.setVertexBuffer!(NuklearVertex)(this.m_vertexBuffer);

		this.m_convertConfig.vertex_layout = this.m_vertexLayout.ptr;
		this.m_convertConfig.vertex_size = NuklearVertex.sizeof;
		this.m_convertConfig.vertex_alignment = 0;
		this.m_convertConfig.null_ = this.m_nullTexture;
		this.m_convertConfig.circle_segment_count = 22;
		this.m_convertConfig.curve_segment_count = 22;
		this.m_convertConfig.arc_segment_count = 22;
		this.m_convertConfig.global_alpha = 1.0f;
		this.m_convertConfig.shape_AA = NK_ANTI_ALIASING_ON;
		this.m_convertConfig.line_AA = NK_ANTI_ALIASING_ON;

		gl.BindTexture(GL_TEXTURE_2D, 0);
		gl.BindBuffer(GL_ARRAY_BUFFER, 0);
		gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		gl.BindVertexArray(0);
	}

	public void dispose()
	{
		nk_font_atlas_clear(&this.m_fontAtlas);
		nk_free(&this.m_nuklearContext);
		nk_buffer_free(&this.m_commands);

		this.m_fontTexture.dispose();
	}

	public void setFont(in string name, in int size)
	{
		nk_font_atlas_init_default(&this.m_fontAtlas);
		nk_font_atlas_begin(&this.m_fontAtlas);
		nk_font* font = nk_font_atlas_add_from_file(&this.m_fontAtlas, cast(char*) name.ptr, size, null);

		int w, h;
		const(void*) image = nk_font_atlas_bake(&this.m_fontAtlas, &w, &h, NK_FONT_ATLAS_RGBA32);

		this.m_fontTexture = Texture.fromMemory(w, h, image);

		nk_font_atlas_end(&this.m_fontAtlas, nk_handle_id(this.m_fontTexture.id), &this.m_nullTexture);
		nk_style_set_font(&this.m_nuklearContext, &font.handle);
	}

	public void draw()
	{
		enum maxVertexBuffer = 512 * 1024;
		enum maxElementBuffer = 128 * 1024;

		GLfloat[4][4] ortho = [
			[2.0f, 0.0f, 0.0f, 0.0f],
			[0.0f,-2.0f, 0.0f, 0.0f],
			[0.0f, 0.0f,-1.0f, 0.0f],
			[-1.0f,1.0f, 0.0f, 1.0f],
		];
		ortho[0][0] /= cast(GLfloat) this.m_windowSize.width;
		ortho[1][1] /= cast(GLfloat) this.m_windowSize.height;

		gl.Enable(GL_BLEND);
		gl.BlendEquation(GL_FUNC_ADD);
		gl.BlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		gl.Disable(GL_CULL_FACE);
		gl.Disable(GL_DEPTH_TEST);
		gl.Enable(GL_SCISSOR_TEST);
		gl.ActiveTexture(GL_TEXTURE0);

		this.m_graphicsDevice.enableShader(this.m_nuklearShader);
		this.m_graphicsDevice.setUniform!("1i", int)(this.m_nuklearShader.textureLocation, 0);
		this.m_graphicsDevice.setMatrix(this.m_nuklearShader.projectionMatrixLocation, &ortho[0][0]);
		this.m_graphicsDevice.setViewport(this.m_frameBufferSize.width, this.m_frameBufferSize.height);
		{

			/* allocate vertex and element buffer */
			this.m_graphicsDevice.bindVAO(this.m_vao);

			this.m_graphicsDevice.allocVertexBufferData(this.m_vertexBuffer, maxVertexBuffer, null, BufferUsage.StreamDraw);
			this.m_graphicsDevice.allocIndexBufferData(this.m_indexBuffer, maxElementBuffer, null, BufferUsage.StreamDraw);

			/* load draw vertices & elements directly into vertex + element buffer */
			void* vertices = gl.MapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
			void* elements = gl.MapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);
			{
				/* fix color bug */
				this.m_convertConfig.null_ = this.m_nullTexture;

				/* setup buffers to load vertices and elements */
				nk_buffer vbuf, ebuf;
				nk_buffer_init_fixed(&vbuf, vertices, cast(size_t) maxVertexBuffer);
				nk_buffer_init_fixed(&ebuf, elements, cast(size_t) maxElementBuffer);
				nk_convert(&this.m_nuklearContext, &this.m_commands, &vbuf, &ebuf, &this.m_convertConfig);
			}
			gl.UnmapBuffer(GL_ARRAY_BUFFER);
			gl.UnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

			nk_draw_index *offset = null;

			/* iterate over and execute each draw command */
			nk_draw_foreach(&this.m_nuklearContext, &this.m_commands, (cmd)
			{
				if (!cmd.elem_count) return;
				gl.BindTexture(GL_TEXTURE_2D, cast(GLuint) cmd.texture.id);
				gl.Scissor(
					cast(GLint)(cmd.clip_rect.x * this.m_frameBufferScale.x),
					cast(GLint)((this.m_windowSize.height - cast(GLint) (cmd.clip_rect.y + cmd.clip_rect.h)) * this.m_frameBufferScale.y),
					cast(GLint)(cmd.clip_rect.w * this.m_frameBufferScale.x),
					cast(GLint)(cmd.clip_rect.h * this.m_frameBufferScale.y)
				);
				gl.DrawElements(GL_TRIANGLES, cast(GLsizei) cmd.elem_count, GL_UNSIGNED_SHORT, offset);
				offset += cmd.elem_count;
			});
			nk_clear(&this.m_nuklearContext);
		}

		this.m_graphicsDevice.disableShader();

		gl.BindBuffer(GL_ARRAY_BUFFER, 0);
		gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		gl.BindVertexArray(0);
		gl.Disable(GL_BLEND);
		gl.Disable(GL_SCISSOR_TEST);
	}

	public void prepareNewFrame()
	{
		int width, height;
		int fbWidth, fbHeight;

		glfwGetWindowSize(this.m_window, &width, &height);
		glfwGetFramebufferSize(this.m_window, &fbWidth, &fbHeight);

		this.m_windowSize = Size!int(width, height);
		this.m_frameBufferSize = Size!int(fbWidth, fbHeight);
		this.m_frameBufferScale = Size!float(
			cast(float) fbWidth / cast(float) width,
			cast(float) fbHeight / cast(float) height
		);

		nk_input_begin(&this.m_nuklearContext);
		/*for (int i = 0; i < glfw.text_len; ++i)
		{
			nk_input_unicode(&this.m_nuklearContext, glfw.text[i]);
		}*/

		/* optional grabbing behavior */
	    if (this.m_nuklearContext.input.mouse.grab)
		{
			glfwSetInputMode(this.m_window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
		}
		else if (this.m_nuklearContext.input.mouse.ungrab)
		{
			glfwSetInputMode(this.m_window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
		}

		nk_input_key(&this.m_nuklearContext, NK_KEY_DEL, glfwGetKey(this.m_window, GLFW_KEY_DELETE) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_ENTER, glfwGetKey(this.m_window, GLFW_KEY_ENTER) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_TAB, glfwGetKey(this.m_window, GLFW_KEY_TAB) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_BACKSPACE, glfwGetKey(this.m_window, GLFW_KEY_BACKSPACE) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_UP, glfwGetKey(this.m_window, GLFW_KEY_UP) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_DOWN, glfwGetKey(this.m_window, GLFW_KEY_DOWN) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_START, glfwGetKey(this.m_window, GLFW_KEY_HOME) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_END, glfwGetKey(this.m_window, GLFW_KEY_END) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_SCROLL_START, glfwGetKey(this.m_window, GLFW_KEY_HOME) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_SCROLL_END, glfwGetKey(this.m_window, GLFW_KEY_END) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_SCROLL_DOWN, glfwGetKey(this.m_window, GLFW_KEY_PAGE_DOWN) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_SCROLL_UP, glfwGetKey(this.m_window, GLFW_KEY_PAGE_UP) == GLFW_PRESS);
		nk_input_key(&this.m_nuklearContext, NK_KEY_SHIFT, 
			glfwGetKey(this.m_window, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS || glfwGetKey(this.m_window, GLFW_KEY_RIGHT_SHIFT) == GLFW_PRESS);

		if (glfwGetKey(this.m_window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS || glfwGetKey(this.m_window, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS) 
		{
			nk_input_key(&this.m_nuklearContext, NK_KEY_COPY, glfwGetKey(this.m_window, GLFW_KEY_C) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_PASTE, glfwGetKey(this.m_window, GLFW_KEY_V) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_CUT, glfwGetKey(this.m_window, GLFW_KEY_X) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_UNDO, glfwGetKey(this.m_window, GLFW_KEY_Z) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_REDO, glfwGetKey(this.m_window, GLFW_KEY_R) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_WORD_LEFT, glfwGetKey(this.m_window, GLFW_KEY_LEFT) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_WORD_RIGHT, glfwGetKey(this.m_window, GLFW_KEY_RIGHT) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_LINE_START, glfwGetKey(this.m_window, GLFW_KEY_B) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_TEXT_LINE_END, glfwGetKey(this.m_window, GLFW_KEY_E) == GLFW_PRESS);
		} 
		else 
		{
			nk_input_key(&this.m_nuklearContext, NK_KEY_LEFT, glfwGetKey(this.m_window, GLFW_KEY_LEFT) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_RIGHT, glfwGetKey(this.m_window, GLFW_KEY_RIGHT) == GLFW_PRESS);
			nk_input_key(&this.m_nuklearContext, NK_KEY_COPY, 0);
			nk_input_key(&this.m_nuklearContext, NK_KEY_PASTE, 0);
			nk_input_key(&this.m_nuklearContext, NK_KEY_CUT, 0);
			nk_input_key(&this.m_nuklearContext, NK_KEY_SHIFT, 0);
		}

		double x, y;
		glfwGetCursorPos(this.m_window, &x, &y);
		nk_input_motion(&this.m_nuklearContext, cast(int) x, cast(int) y);

		if (this.m_nuklearContext.input.mouse.grabbed) 
		{
			glfwSetCursorPos(this.m_window, this.m_nuklearContext.input.mouse.prev.x, this.m_nuklearContext.input.mouse.prev.y);
			this.m_nuklearContext.input.mouse.pos.x = this.m_nuklearContext.input.mouse.prev.x;
			this.m_nuklearContext.input.mouse.pos.y = this.m_nuklearContext.input.mouse.prev.y;
		}

		nk_input_button(&this.m_nuklearContext, NK_BUTTON_LEFT, cast(int) x, cast(int)y, glfwGetMouseButton(this.m_window, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS);
		nk_input_button(&this.m_nuklearContext, NK_BUTTON_MIDDLE, cast(int) x, cast(int)y, glfwGetMouseButton(this.m_window, GLFW_MOUSE_BUTTON_MIDDLE) == GLFW_PRESS);
		nk_input_button(&this.m_nuklearContext, NK_BUTTON_RIGHT, cast(int) x, cast(int)y, glfwGetMouseButton(this.m_window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS);
		nk_input_button(&this.m_nuklearContext, NK_BUTTON_DOUBLE, 
			cast(int) this.m_doubleClickPos.x, cast(int) this.m_doubleClickPos.y, this.m_isDoubleClickDown);

		//nk_input_scroll(&this.m_nuklearContext, glfw.scroll);
		nk_input_end(&this.m_nuklearContext);
		/*glfw.text_len = 0;
		glfw.scroll = nk_vec2(0,0);*/
	}

	@nogc @safe
	@property pure nothrow
	{
		public nk_context* context()
		{
			return &this.m_nuklearContext;
		}
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
	 *		position : mouse position
	 */
	public void onMouseUp(in MouseButton mouseButton, in ref vec2 position)
	{
		this.m_isDoubleClickDown = nk_false;
	}
}

// extern(C) void nk_glfw3_char_callback(GLFWwindow *win, uint codepoint) nothrow
// {
//     if (glfw.text_len < NK_GLFW_TEXT_MAX)
//         glfw.text[glfw.text_len++] = codepoint;
// }

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

class NuklearShader : Shader
{
	public int textureLocation;
	public int projectionMatrixLocation;

	public this(Shader shader)
	{
		super(shader);

		this.textureLocation = this.getUniformLocation("Texture");
		this.projectionMatrixLocation = this.getUniformLocation("ProjMtx");
	}
}