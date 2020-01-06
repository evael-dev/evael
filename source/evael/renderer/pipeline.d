module evael.renderer.pipeline;

import evael.renderer.enums;
import evael.renderer.shader;
import evael.renderer.texture;
import evael.renderer.blend_state;
import evael.renderer.depth_state;
import evael.renderer.resources;
import evael.renderer.buffer;

import evael.lib.memory;
import evael.lib.containers;

abstract class Pipeline
{
    public uint primitiveType;

    public Shader shader;
    
    public BlendState blendState;
    
    public DepthState depthState;

	protected Array!Resource m_resources;

    @nogc
    public this()
    {
    }

    @nogc
    public ~this()
    {
        foreach (resource; this.m_resources)
        {
            MemoryHelper.dispose(resource);
        }

        this.m_resources.dispose();
    }

    @nogc
    public abstract TextureResource addTextureResource(Texture texture = null);

    @nogc
    @property nothrow
    public ref Array!Resource resources()
    {
        return this.m_resources;
    }

}