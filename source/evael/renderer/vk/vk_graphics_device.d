module evael.renderer.vk.vk_graphics_device;

import evael.renderer.graphics_device;
import evael.renderer.vk.vk_command;

import evael.lib.memory;
import evael.lib.containers.array;

class VkGraphicsDevice : GraphicsDevice
{
	private Array!GraphicsBuffer m_buffers;

	/**
	 * VkGraphicsDevice constructor.
	 */
	public this()
	{
	}

	/**
	 * VkGraphicsDevice destructor.
	 */
	public ~this()
	{
		foreach (buffer; this.m_buffers)
		{
		}

		this.m_buffers.dispose();
	}
	
	@nogc
	public override GraphicsCommand createCommand()
	{
		return MemoryHelper.create!VkCommand();
	}

	/**
	 * Create a vertex buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public override GraphicsBuffer createVertexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow
	{
        return GraphicsBuffer();
	}

	/**
	 * Creates an index buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public override GraphicsBuffer createIndexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow
	{
		return GraphicsBuffer();
	}

	/**
	 * Deletes a buffer object.
	 * Params:
	 *		buffer : buffer
	 */
	@nogc
	public override void deleteBuffer(in GraphicsBuffer bufferToDelete)
	{
		foreach (i, buffer; this.m_buffers)
		{
			if(buffer.id == bufferToDelete.id)
			{
				this.m_buffers.removeAt(i);
				break;
			}
		}
	}

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 buffer : buffer
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public override void updateBuffer(in GraphicsBuffer buffer, in long offset, in ptrdiff_t size, in void* data) const nothrow
	{

	}

	/**
	 * Generates a buffer object.
	 * Params:
	 *		type : buffer object type
	 */
	@nogc
    private GraphicsBuffer generateBuffer(in uint type) nothrow
	{
		uint id;

		GraphicsBuffer buffer = {
			id: id,
			type: type
		};

		this.m_buffers.insert(buffer);

		return buffer;
	}
} 