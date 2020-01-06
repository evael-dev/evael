module evael.renderer.gl.gl_device;

import evael.renderer.device;
import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;

import evael.lib.image.image;
import evael.lib.memory;
import evael.lib.containers.array;

class GLDevice : Device
{
	private uint m_vao;

	/**
	 * GLDevice constructor.
	 */
	@nogc
	public this()
	{
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
		gl.GenVertexArrays(1, &this.m_vao);
		gl.BindVertexArray(this.m_vao);
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