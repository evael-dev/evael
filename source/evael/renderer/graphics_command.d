module evael.renderer.graphics_command;


/**
 * GraphicsCommand is the base class for all the API commands.
 */
abstract class GraphicsCommand
{
	/**
	 * GraphicsCommand constructor.
	 */
	private this()
		this.m_renderer = renderer;
	}

	/**
	 * GraphicsCommand destructor.
	 */
	public void dispose()
	{

	}
} 