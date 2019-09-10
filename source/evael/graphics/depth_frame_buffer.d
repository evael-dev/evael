module evael.graphics.depth_frame_buffer;

import evael.graphics.graphics_device;
import evael.graphics.texture;
import evael.graphics.frame_buffer;

/**
 * DepthFrameBuffer.
 */
class DepthFrameBuffer : FrameBuffer
{
	private uint m_depthBuffer;
	
	/**
	 * DepthFrameBuffer constructor.
	 * Params:
	 *		graphics : graphics device
	 *		width : width
	 *		height : height
	 */
	public this(GraphicsDevice graphics, in int width, in int height) nothrow
	{
		super(graphics, width, height);
		
		gl.GenRenderbuffers(1, &this.m_depthBuffer);
		
		this.m_texture = Texture.generateEmptyTexture();

		this.m_graphicsDevice.bindTexture(this.m_texture);

		gl.TexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, null);
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		gl.BindTexture(GL_TEXTURE_2D, 0);

		gl.BindFramebuffer(GL_FRAMEBUFFER, this.m_id);  
		gl.BindRenderbuffer(GL_RENDERBUFFER, this.m_depthBuffer);
		gl.RenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);
		
		// Attach it to currently bound framebuffer object
		gl.FramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, this.m_texture.id, 0); 
		gl.FramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, this.m_depthBuffer);
		
		gl.BindRenderbuffer(GL_RENDERBUFFER, 0);        
	}
	
	/**
	 * DepthFrameBuffer destructor.
	 */
	@nogc
	public override void dispose() const nothrow
	{
		super.dispose();
		gl.DeleteRenderbuffers(1, &this.m_depthBuffer);
	}
	
}