module evael.graphics.texture_array;

import std.typecons : Flag, Yes, No;

import evael.graphics.gl;

import evael.system.asset;

import evael.graphics.graphics_device;
import evael.graphics.texture;

/**
 * TextureArray.
 */
class TextureArray
{
	/// Texture array ID
	private uint m_id;

	/** 
	 * TextureArray constructor.
	 */
	@nogc
	public this(in uint id) nothrow
	{
        this.m_id = id;
	}

	/** 
	 * TextureArray destructor.
	 */
	@nogc
	public void dispose() const nothrow
	{
		gl.DeleteBuffers(1, &this.m_id);
	}

	/**
	 * Builds a texture array from multiple textures.
	 * Params:
	 *		textures : textures to load
	 *		size : textures width and height
     *      flipTexture : flip each texture ?
	 */
	public static TextureArray build(in string[] textures, in int size = 512, in Flag!"flipTextures" flipTextures = Yes.flipTextures)
	{
        uint id;
		gl.GenTextures(1, &id);

        gl.ActiveTexture(GL_TEXTURE2);
        gl.BindTexture(GL_TEXTURE_2D_ARRAY, id);

		gl.TexImage3D(GL_TEXTURE_2D_ARRAY,
			0,                 		   // mipmap level
			GL_RGBA8,          		   // gpu texel format
			size,              		   // width
			size,              		   // height
			cast(int) textures.length, // depth
			0,                 		   // border
			GL_BGRA,      	   		   // cpu pixel format
			GL_UNSIGNED_BYTE,  		   // cpu pixel coord type
			null);             		   // pixel data
		
        foreach (i, texture; textures)
        {
            auto bytes = Texture.loadBytes(texture);
            gl.TexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, cast(int) i, size, size, 1, GL_BGRA, GL_UNSIGNED_BYTE, bytes.ptr);
        }

		auto minificationFilter = GL_LINEAR;
		auto magnificationFilter = GL_LINEAR;

		// Anisotropic filter
		float fLargest;
		gl.GetFloatv(0x84FF, &fLargest);
		gl.TexParameterf(GL_TEXTURE_2D_ARRAY, 0x84FE, fLargest);

		// Specify our minification and magnification filters
		gl.TexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, minificationFilter);
		gl.TexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, magnificationFilter);

		// If we're using MipMaps, then we'll generate them here.
		// Note: The glGenerateMipmap call requires OpenGL 3.0 as a minimum.
		if (minificationFilter == GL_LINEAR_MIPMAP_LINEAR   ||
			minificationFilter == GL_LINEAR_MIPMAP_NEAREST  ||
			minificationFilter == GL_NEAREST_MIPMAP_LINEAR  ||
			minificationFilter == GL_NEAREST_MIPMAP_NEAREST)
		{
			gl.GenerateMipmap(GL_TEXTURE_2D_ARRAY);
		}

        gl.BindTexture(GL_TEXTURE_2D_ARRAY, 0);
        gl.ActiveTexture(GL_TEXTURE20);

        return new TextureArray(id);
    }

	/**
	 * Properties
	 */
	@nogc
	@property nothrow
	{
		public uint id() const
		{
			return this.m_id;	
		}
    }
}

