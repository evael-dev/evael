module evael.renderer.gl.gl_texture;

import evael.renderer.gl.gl_wrapper;
import evael.renderer.texture;

class GLTexture : Texture
{
    private uint m_id;

    /**
     * GLTexture constructor.
     */
    @nogc
    public this()
    {
        super();
        
        gl.GenTextures(1, &this.m_id);
    }

    /**
     * GLTexture destructor.
     */
    @nogc
    public ~this()
    {
        gl.DeleteTextures(1, &this.m_id);
    }


    /**
     * Loads a texture.
     * Params:
     *      fileName : texture to load
     */
    public static GLTexture load(in string fileName)
    {
        import evael.lib.memory : MemoryHelper;
        import evael.lib.image.image : Image;

        auto texture = MemoryHelper.create!GLTexture();

        auto image = Image.fromFile(fileName);

        gl.BindTexture(GL_TEXTURE_2D, texture.id);
        gl.TexImage2D(GL_TEXTURE_2D,
                    0,                // Mipmap level (0 being the top level i.e. full size)
                    GL_RGBA,          // Internal format
                    image.width,      // Width of the texture
                    image.height,     // Height of the texture,
                    0,                // Border in pixels
                    GL_BGRA,          // Data format
                    GL_UNSIGNED_BYTE, // Type of texture data
                    image.bytes);     // The image data to use for this texture
    
        MemoryHelper.dispose(image);
        
        auto minificationFilter = GL_LINEAR;
        auto magnificationFilter = GL_LINEAR;

        // Anisotropic filter
        float fLargest;
        gl.GetFloatv(0x84FF, &fLargest);
        gl.TexParameterf(GL_TEXTURE_2D, 0x84FE, fLargest);

        // Specify our minification and magnification filters
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minificationFilter);
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magnificationFilter);
    
        // If we're using MipMaps, then we'll generate them here.
        // Note: The glGenerateMipmap call requires OpenGL 3.0 as a minimum.
        if (minificationFilter == GL_LINEAR_MIPMAP_LINEAR   ||
            minificationFilter == GL_LINEAR_MIPMAP_NEAREST  ||
            minificationFilter == GL_NEAREST_MIPMAP_LINEAR  ||
            minificationFilter == GL_NEAREST_MIPMAP_NEAREST)
        {
            gl.GenerateMipmap(GL_TEXTURE_2D);
        }
    
        return texture;
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

