module evael.renderer.graphics_device;

import evael.renderer.renderer;

class GraphicsDevice
{
	private Renderer m_renderer;

	/**
	 * GraphicsDevice constructor.
	 */
	private this(Renderer renderer)
	{
		this.m_renderer = renderer;
	}

	/**
	 * GraphicsDevice destructor.
	 */
	public void dispose()
	{

	}
} 