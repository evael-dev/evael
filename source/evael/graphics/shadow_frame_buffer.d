module evael.graphics.shadow_frameèbuffer;

import evael.graphics.graphics_device;
import evael.graphics.texture;
import evael.graphics.frame_buffer;

/**
 * ShadowFrameBuffer.
 */
class ShadowFrameBuffer : FrameBuffer
{
	/**
	 * ShadowFrameBuffer constructor.
	 * Params:
	 *		graphics : graphics device
	 *		width : width
	 *		height : height
	 */
	public this(GraphicsDevice graphics, in int width, in int height) nothrow
	{
        super(graphics, width, height);

		this.m_texture = Texture.generateEmptyTexture();

		this.m_graphicsDevice.bindTexture(this.m_texture);
        
		gl.TexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT16, width, height, 0, GL_DEPTH_COMPONENT, GL_FLOAT, null);
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);

		float[4] borderColor = [ 1.0, 1.0, 1.0, 1.0 ];
		glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor.ptr);  

		gl.BindTexture(GL_TEXTURE_2D, 0);

		gl.BindFramebuffer(GL_FRAMEBUFFER, this.m_id);  
		gl.FramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, this.m_texture.id, 0); 
        gl.DrawBuffer(GL_NONE);
        
		gl.BindFramebuffer(GL_FRAMEBUFFER, 0);
	}
}