module evael.renderer.vk.vk_texture;

import evael.renderer.vk.vk_wrapper;
import evael.renderer.texture;

class VulkanTexture : Texture
{
	/**
	 * VkTexture constructor.
	 */
	@nogc
	public this()
	{
		super();
		
	}

	/**
	 * VkTexture destructor.
	 */
	@nogc
	public ~this()
	{
		this.dispose();
	}

	// TODO: remove this when IAsset is cleaned.
	@nogc
	public void dispose()
	{
	}

	/**
	 * Loads a texture.
	 * Params:
	 *      fileName : texture to load
	 */
	public static VulkanTexture load(in string fileName)
	{
		import evael.lib.memory : MemoryHelper;
		import evael.lib.image.image : Image;

		auto texture = MemoryHelper.create!VulkanTexture();
		return texture;
	}

	@nogc
	@property nothrow
	{

	}
}

