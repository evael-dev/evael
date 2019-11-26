module evael.renderer.gl.gl_texture;

import evael.renderer.texture;

class GLTexture : Texture
{
    private uint m_id;

    /**
     * GLTexture constructor.
     */
    @nogc
    public this(in uint id)
    {
        super();
        
        this.m_id = id;
    }

    @nogc
    @property nothrow
    {
        public uint id() const
        {
            return this.m_id;
        }
    }
    
}

