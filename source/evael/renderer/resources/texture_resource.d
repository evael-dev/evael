module evael.renderer.resources.texture_resource;

import evael.renderer.resources.resource;
import evael.renderer.enums.resource_type;
import evael.renderer.texture;

abstract class TextureResource : Resource
{
    private Texture m_texture;
    
    @nogc
    public this(Texture texture)
    {
        super(ResourceType.Texture);

        this.m_texture = texture;
    }
    
    @nogc
    @property nothrow
    public Texture texture()
    {
        return this.m_texture;
    }
}