module evael.graphics.gui.core.renderer;

import bindbc.nuklear;
import bindbc.glfw;

import evael.graphics.graphics_device;
import evael.graphics.gl;
import evael.graphics.texture;
import evael.graphics.shaders.shader;
import evael.graphics.vertex;

import evael.system.asset_loader;

import evael.utils.size;

alias NuklearVertex = Vertex2PositionColorTexture;

/**
 * Renderer.
 * Nuklear renderer.
 */
class Renderer
{
	private GLFWwindow* m_window;
	private nk_context* m_nuklearContext;

	private GraphicsDevice m_graphicsDevice;

	private nk_draw_null_texture m_nullTexture;

	private nk_buffer m_commands;
	private nk_draw_index* m_drawOffset;

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

	public this(GraphicsDevice graphicsDevice, GLFWwindow* window, nk_context* nuklearContext)
	{
		this.m_graphicsDevice = graphicsDevice;
		this.m_window = window;
		this.m_nuklearContext = nuklearContext;

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
		nk_buffer_free(&this.m_commands);
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
				nk_convert(this.m_nuklearContext, &this.m_commands, &vbuf, &ebuf, &this.m_convertConfig);
			}
			gl.UnmapBuffer(GL_ARRAY_BUFFER);
			gl.UnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

			this.m_drawOffset = null;

			/* iterate over and execute each draw command */
			nk_draw_foreach(this.m_nuklearContext, &this.m_commands, &this.drawElement);
			nk_clear(this.m_nuklearContext);
		}

		this.m_graphicsDevice.disableShader();

		gl.BindBuffer(GL_ARRAY_BUFFER, 0);
		gl.BindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		gl.BindVertexArray(0);
		gl.Disable(GL_BLEND);
		gl.Disable(GL_SCISSOR_TEST);
	}

	@nogc
	private void drawElement(const(nk_draw_command)* cmd) nothrow
	{
		if (!cmd.elem_count) return;
		// gl.BindTexture(GL_TEXTURE_2D, cast(GLuint) cmd.texture.id);
		gl.Scissor(
			cast(GLint)(cmd.clip_rect.x * this.m_frameBufferScale.x),
			cast(GLint)((this.m_windowSize.height - cast(GLint) (cmd.clip_rect.y + cmd.clip_rect.h)) * this.m_frameBufferScale.y),
			cast(GLint)(cmd.clip_rect.w * this.m_frameBufferScale.x),
			cast(GLint)(cmd.clip_rect.h * this.m_frameBufferScale.y)
		);
		gl.DrawElements(GL_TRIANGLES, cast(GLsizei) cmd.elem_count, GL_UNSIGNED_SHORT, this.m_drawOffset);
		this.m_drawOffset += cmd.elem_count;
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
	}

	private class NuklearShader : Shader
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
}