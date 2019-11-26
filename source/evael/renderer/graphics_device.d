module evael.renderer.graphics_device;

import evael.lib.memory.no_gc_class;

public 
{
	import evael.renderer.graphics_buffer;
	import evael.renderer.graphics_command;
	import evael.renderer.shader;
	import evael.renderer.texture;

	import evael.renderer.enums.buffer_type;
}

abstract class GraphicsDevice : NoGCClass
{
	/**
	 * GraphicsDevice constructor.
	 */
	@nogc
	public this()
	{
	}

	/**
	 * GraphicsDevice destructor.
	 */
	@nogc
	public ~this()
	{

	}

	/**
	 * Create a buffer object.
	 * Params:
	 *		type : buffer type
	 *		size : buffer object size
	 *		data : data to send
	 */
	@nogc
	public abstract GraphicsBuffer createBuffer(BufferType type, in ptrdiff_t size, in void* data = null) nothrow;

	/**
	 * Deletes a buffer object.
	 * Params:
	 *		buffer : buffer
	 */
	@nogc
	public abstract void deleteBuffer(in GraphicsBuffer buffer);

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 buffer : buffer
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public abstract void updateBuffer(ref GraphicsBuffer buffer, in long offset, in ptrdiff_t size, in void* data) const nothrow;

	public abstract Shader createShader(in string vertexSource, in string fragmentSource) const;

	@nogc
	public abstract Texture createTexture() const;

	public abstract Texture createTexture(in string name) const;
} 