module evael.renderer.vk.vk_pipeline;

import evael.renderer.pipeline;
import evael.renderer.graphics_buffer;

import evael.renderer.vk.vk_shader;
import evael.renderer.vk.vk_wrapper;
import evael.renderer.vk.vk_uniform_resource;
import evael.renderer.vk.vk_texture_resource;
import evael.renderer.vk.vk_enum_converter;

import evael.renderer.resources.resource;
import evael.renderer.texture;

import evael.lib.memory;

class VulkanPipeline : Pipeline
{
    @nogc
    public override void apply() const nothrow
    {
        if (this.depthState.enabled)
        {

        }
        
        if (this.blendState.enabled)
        {
        
        }

        foreach (resource; this.m_resources)
        {
            resource.apply();
        }
    }

    @nogc
    public override void clear() const nothrow
    {
        foreach (resource; this.m_resources)
        {
            resource.clear();
        }

        if (this.blendState.enabled)
        {
        }

        if (this.depthState.enabled)
        {
        }
    }

    @nogc
    public override VulkanTextureResource addTextureResource(Texture texture = null)
    {
        auto resource = MemoryHelper.create!VulkanTextureResource(texture);
        this.m_resources.insert(resource);
        return resource;
    }

    @nogc
    public VulkanUniformResource!T addUniformResource(T)(in string name, T value)
    {
        assert(this.shader !is null, "Set a shader before adding an uniform resource.");

        return null;
    }
}