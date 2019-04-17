module evael.graphics.FrameBuffer;

import evael.graphics.GraphicsDevice;
import evael.graphics.Texture;

/**
 * FrameBuffer.
 */
class FrameBuffer
{
	protected GraphicsDevice m_graphicsDevice;
	protected uint 			 m_id;
	protected Texture 		 m_texture;

	/**
	 * FrameBuffer constructor.
	 * Params:
	 *		graphics : graphics device
	 *		width : width
	 *		height : height
	 */
	@nogc
	public this(GraphicsDevice graphics, in int width, in int height) nothrow
	{
		this.m_graphicsDevice = graphics;

		gl.GenFramebuffers(1, &this.m_id);
    }

	/**
	 * FrameBuffer destructor.
	 */
	@nogc
    public void dispose() const nothrow
    {
        gl.DeleteFramebuffers(1, &this.m_id);
    }
    
	/**
	 * Properties
	 */
	@nogc @safe
	@property pure nothrow
	{
		public uint id() const
		{
			return this.m_id;
		}

		public Texture texture()
		{
			return this.m_texture;
		}
	}
}