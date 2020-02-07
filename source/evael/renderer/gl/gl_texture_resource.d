module evael.renderer.gl.gl_texture_resource;

import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_texture;

import evael.renderer.texture;

import evael.renderer.resources.texture_resource;

class GLTextureResource : TextureResource
{   
	private GLTexture m_glTexture;
	
	@nogc
	public this(Texture texture)
	{
		super(texture);

		this.m_glTexture = cast(GLTexture) texture;
	}

	@nogc
	public override void apply() const nothrow
	{
		gl.BindTexture(GL_TEXTURE_2D, this.m_glTexture.id);
	}

	@nogc
	public override void clear() const nothrow
	{
		gl.BindTexture(GL_TEXTURE_2D, 0);
	}
}

