module evael.renderer.graphics_device;

import evael.renderer.buffer;
import evael.renderer.graphics_command;

abstract class GraphicsDevice
{
	/**
	 * GraphicsDevice constructor.
	 */
	public this()
	{
	}

	/**
	 * GraphicsDevice destructor.
	 */
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
	public abstract uint createVertexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow;

	/**
	 * Creates an index buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public abstract uint createIndexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow;

	/**
	 * Deletes a buffer object.
	 * Params:
	 *		id : buffer id
	 */
	@nogc
	public abstract void deleteBuffer(in uint id) nothrow;

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 id : buffer object
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public abstract void updateBuffer(in uint id, in long offset, in ptrdiff_t size, in void* data) const nothrow;
} 