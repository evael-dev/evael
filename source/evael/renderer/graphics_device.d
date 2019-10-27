module evael.renderer.graphics_device;

import evael.lib.memory.no_gc_class;

public 
{
	import evael.renderer.graphics_buffer;
	import evael.renderer.graphics_command;
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

	@nogc
	public abstract GraphicsCommand createCommand();
	
	/**
	 * Create a vertex buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public abstract GraphicsBuffer createVertexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow;

	/**
	 * Creates an index buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public abstract GraphicsBuffer createIndexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow;

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
	public abstract void updateBuffer(in GraphicsBuffer buffer, in long offset, in ptrdiff_t size, in void* data) const nothrow;
} 