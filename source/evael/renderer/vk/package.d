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
    
    alias GraphicsDevice = VulkanDevice;
    alias GraphicsCommand = VulkanCommand;
    alias Pipeline = VulkanPipeline;
    alias Texture = VulkanTexture;
    alias Shader = VulkanShader;
    alias GraphicsBuffer = VulkanBuffer;
    alias UniformResource = VulkanUniformResource;
    alias TextureResource = VulkanTextureResource;
}