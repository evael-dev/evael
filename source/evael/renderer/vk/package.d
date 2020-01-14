module evael.renderer.vk;

public
{
	import evael.renderer.vk.vk_device;
	import evael.renderer.vk.vk_command;
	
	import evael.renderer.vk.vk_texture;
	import evael.renderer.vk.vk_shader;
	import evael.renderer.vk.vk_pipeline;
	import evael.renderer.vk.vk_buffer;
	import evael.renderer.vk.vk_uniform_resource;
	import evael.renderer.vk.vk_texture_resource;
	
	alias Device = VkDevice;
	alias Command = VkCommand;
	alias Pipeline = VkPipeline;
	alias Texture = VkTexture;
	alias Shader = VkShader;
	alias Buffer = VkBuffer;
	alias UniformResource = VkUniformResource;
	alias TextureResource = VkTextureResource;
}