module evael.renderer.vk.vk_texture_resource;

import evael.renderer.vk.vk_wrapper;
import evael.renderer.vk.vk_texture;

import evael.renderer.texture;

import evael.renderer.resources.texture_resource;

class VulkanTextureResource : TextureResource
{   
	private VulkanTexture m_vkTexture;
	
	@nogc
	public this(Texture texture)
	{
		super(texture);

		this.m_vkTexture = cast(VulkanTexture) texture;
	}

	@nogc
	public override void apply() const nothrow
	{
	}

	@nogc
	public override void clear() const nothrow
	{
	}
}

