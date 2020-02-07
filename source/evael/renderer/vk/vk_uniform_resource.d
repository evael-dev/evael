module evael.renderer.vk.vk_uniform_resource;

import evael.renderer.vk.vk_wrapper;
import evael.renderer.vk.vk_buffer;

import evael.renderer.resources.uniform_resource;

import evael.lib.memory : MemoryHelper;

class VulkanUniformResource(T) : UniformResource!T
{   
    /**
     * VkUniformResource constructor.
     */
    @nogc
    public this(in string name, in uint programId, T defaultValue)
    {
        super(name);

    }

    @nogc
    public override void apply() const nothrow
    {
    }

    @nogc
    public override void clear() const nothrow
    {
    }

    @nogc
    public override void update() const nothrow
    {
    }

    @nogc
    @property nothrow
    {

    }
}