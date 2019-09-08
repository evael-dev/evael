module evael.graphics.texture;

import std.file : exists;
import std.string : lastIndexOf, format, toStringz;
import std.exception;
import std.typecons : Flag, Yes, No;
import core.stdc.string : strlen;

import bindbc.freeimage;

import evael.graphics.gl;
import evael.core.game_config;
import evael.system.asset;
import evael.utils.size;

/**
 * Texture.
 */
class Texture : IAsset
{
	private Size!int m_size;
	private uint 	 m_id;
	
	/// NanoVG texture id.
	private uint m_nvgId;

	/**
	 * Texture constructor.
	 * Params:
	 *		id : texture id
	 */
	@nogc
	public this(in uint id) nothrow
	{
		this.m_id = id;
	}

	/**
	 * Texture constructor.
	 * Params:
	 *		id : texture id
	 *		size : texture size
	 */
	@nogc
	public this(in uint id, in Size!int size) nothrow
	{
		this.m_id = id;
		this.m_size = size;
	}	
	
	/**
	 * Texture destructor.
	 */
	@nogc
	public void dispose() const nothrow 
	{
		gl.DeleteBuffers(1, &this.m_id);
	}

	/**
	 * Loads texture.
	 * Params:
	 *		textureName : texture to load
	 * Credits: http://r3dux.org/2014/10/how-to-load-an-opengl-texture-using-the-freeimage-library-or-freeimageplus-technically/
	 */
	public static Texture load(in string textureName, in bool flipTexture = true)
	{
		import evael.core.game_config;

		immutable fileName = toStringz(GameConfig.paths.textures ~ textureName);

		// Determine the format of the image
		FREE_IMAGE_FORMAT fiFormat = FreeImage_GetFileType(fileName , 0);
	
		// Image not found
		enforce(fiFormat != -1, new Exception(format("File \"%s\" must exists.", textureName)));

		// Found image, but couldn't determine the file format
		if (fiFormat == FIF_UNKNOWN)
		{
			fiFormat = FreeImage_GetFIFFromFilename(fileName);
	
			if (!FreeImage_FIFSupportsReading(fiFormat) )
			{
				throw new Exception("File \"%s\" cannot be read.".format(textureName));
			}
		}
	
		// If we're here we have a known image format, so load the image into a bitmap
		FIBITMAP* bitmap = FreeImage_Load(fiFormat, fileName);
	
		if(flipTexture)
		{
			FreeImage_FlipVertical(bitmap);
		}

		// How many bits-per-pixel is the source image?
		immutable bitsPerPixel =  FreeImage_GetBPP(bitmap);
	
		// Convert our image up to 32 bits (8 bits per channel, Red/Green/Blue/Alpha) -
		// but only if the image is not already 32 bits (i.e. 8 bits per channel).
		// Note: ConvertTo32Bits returns a CLONE of the image data - so if we
		// allocate this back to itself without using our bitmap32 intermediate
		// we will LEAK the original bitmap data
		FIBITMAP* bitmap32;
		if (bitsPerPixel == 32)
		{
			bitmap32 = bitmap;
		}
		else
		{
			bitmap32 = FreeImage_ConvertTo32Bits(bitmap);
		}
	
		// Some basic image info - strip it out if you don't care
		immutable imageWidth  = FreeImage_GetWidth(bitmap32);
		immutable imageHeight = FreeImage_GetHeight(bitmap32);
	
		// Get a pointer to the texture data as an array of unsigned bytes.
		// Note: At this point bitmap32 ALWAYS holds a 32-bit colour version of our image - so we get our data from that.
		// Also, we don't need to delete or delete[] this textureData because it's not on the heap (so attempting to do
		// so will cause a crash) - just let it go out of scope and the memory will be returned to the stack.
		ubyte* textureData = FreeImage_GetBits(bitmap32);
	
		// Generate a texture ID and bind to it
		auto texture = Texture.generateEmptyTexture();
		texture.size = Size!int(imageWidth, imageHeight);

		gl.BindTexture(GL_TEXTURE_2D, texture.id);
	
		// Construct the texture.
		// Note: The 'Data format' is the format of the image data as provided by the image library. FreeImage decodes images into
		// BGR/BGRA format, but we want to work with it in the more common RGBA format, so we specify the 'Internal format' as such.
		gl.TexImage2D(GL_TEXTURE_2D,    // Type of texture
					0,                // Mipmap level (0 being the top level i.e. full size)
					GL_RGBA,          // Internal format
					imageWidth,       // Width of the texture
					imageHeight,      // Height of the texture,
					0,                // Border in pixels
					GL_BGRA,          // Data format
					GL_UNSIGNED_BYTE, // Type of texture data
					textureData);     // The image data to use for this texture
	
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
	
		// Unload the 32-bit colour bitmap
		FreeImage_Unload(bitmap32);
	
		// If we had to do a conversion to 32-bit colour, then unload the original
		// non-32-bit-colour version of the image data too. Otherwise, bitmap32 and
		// bitmap point at the same data, and that data's already been free'd, so
		// don't attempt to free it again! (or we'll crash).
		if (bitsPerPixel != 32)
		{
			FreeImage_Unload(bitmap);
		}
		
		return texture;
	}

	/**
	 * Loads image.
	 * Params:
	 *		textureName : texture to load
	 */
	public static ubyte[] loadBytes(in string textureName, in Flag!"flipTexture" flipTexture = Yes.flipTexture)
	{
		import evael.core.game_config;

		// Texture name without path and extension
		immutable fileName = toStringz(GameConfig.paths.textures ~ textureName);

		// Determine the format of the image
		FREE_IMAGE_FORMAT fiFormat = FreeImage_GetFileType(fileName , 0);
	
		// Image not found
		enforce(fiFormat != -1, new Exception(format("File \"%s\" must exists.", textureName)));

		// Found image, but couldn't determine the file format
		if (fiFormat == FIF_UNKNOWN)
		{
			fiFormat = FreeImage_GetFIFFromFilename(fileName);
	
			if (!FreeImage_FIFSupportsReading(fiFormat) )
			{
				throw new Exception(format("File \"%s\" cannot be read.", textureName));
			}
		}
	
		// If we're here we have a known image format, so load the image into a bitmap
		FIBITMAP* bitmap = FreeImage_Load(fiFormat, fileName);
	
		if(flipTexture)
		{
			FreeImage_FlipVertical(bitmap);
		}

		// How many bits-per-pixel is the source image?
		immutable bitsPerPixel =  FreeImage_GetBPP(bitmap);
	
		// Convert our image up to 32 bits (8 bits per channel, Red/Green/Blue/Alpha) -
		// but only if the image is not already 32 bits (i.e. 8 bits per channel).
		// Note: ConvertTo32Bits returns a CLONE of the image data - so if we
		// allocate this back to itself without using our bitmap32 intermediate
		// we will LEAK the original bitmap data
		FIBITMAP* bitmap32;
		if (bitsPerPixel == 32)
		{
			bitmap32 = bitmap;
		}
		else
		{
			bitmap32 = FreeImage_ConvertTo32Bits(bitmap);
		}
	
		// Get a pointer to the texture data as an array of unsigned bytes.
		// Note: At this point bitmap32 ALWAYS holds a 32-bit colour version of our image - so we get our data from that.
		// Also, we don't need to delete or delete[] this textureData because it's not on the heap (so attempting to do
		// so will cause a crash) - just let it go out of scope and the memory will be returned to the stack.
		ubyte* bytes = FreeImage_GetBits(bitmap32);

		ubyte[] ret = new ubyte[(FreeImage_GetWidth(bitmap32) * FreeImage_GetHeight(bitmap32)) * 4];

		for(int i = 0; i < ret.length; i++)
		{
			ret[i] = bytes[i];
		}

		// Unload the 32-bit colour bitmap
		FreeImage_Unload(bitmap32);
	
		// If we had to do a conversion to 32-bit colour, then unload the original
		// non-32-bit-colour version of the image data too. Otherwise, bitmap32 and
		// bitmap point at the same data, and that data's already been free'd, so
		// don't attempt to free it again! (or we'll crash).
		if (bitsPerPixel != 32)
		{
			FreeImage_Unload(bitmap);
		}
		
		return ret;
	}


	/**
	 * Generates an empty texture.
	 */
	public static Texture generateEmptyTexture() nothrow
	{
		uint id = 0;
		gl.GenTextures(1, &id);

		return new Texture(id);
	}

	/**
	 * Generates a texture from memory data.
	 */
	public static Texture fromMemory(in int width, in int height, const(void*) data,
		in uint minFilter = GL_NEAREST, in uint magFilter = GL_NEAREST)
	{
		auto texture = Texture.generateEmptyTexture();
		gl.BindTexture(GL_TEXTURE_2D, texture.id);
		gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
        gl.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
        gl.TexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, cast(GLsizei) width, cast(GLsizei) height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
		return texture;
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
		
		public void id(in uint value)
		{
			this.m_id = value;
		}
		
		public Size!int size() const
		{
			return this.m_size;	
		}

		public void size(in Size!int value)
		{
			this.m_size = value;
		}

		public uint nvgId() const
		{
			return this.m_nvgId;
		}

		public void nvgId(in uint value)
		{
			this.m_nvgId = value;
		}
	}
}

