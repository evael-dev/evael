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
	
	alias Device = VulkanDevice;
	alias Command = VulkanCommand;
	alias Pipeline = VulkanPipeline;
	alias Texture = VulkanTexture;
	alias Shader = VulkanShader;
	alias Buffer = VulkanBuffer;
	alias UniformResource = VulkanUniformResource;
	alias TextureResource = VulkanTextureResource;
}