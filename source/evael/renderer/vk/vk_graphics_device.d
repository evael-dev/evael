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
	@nogc
	public this()
	{
	}

	/**
	 * VkGraphicsDevice destructor.
	 */
	@nogc
	public ~this()
	{
		foreach (buffer; this.m_buffers)
		{
		}

		this.m_buffers.dispose();
	}
	
	@nogc
	public VkCommand createCommand()
	{
		return MemoryHelper.create!VkCommand();
	}

	/**
	 * Create a buffer object.
	 * Params:
	 *		type : buffer type
	 *		size : buffer object size
	 *		data : data to send
	 */
	@nogc
	public override GraphicsBuffer createBuffer(BufferType type, in ptrdiff_t size, in void* data) nothrow
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
	public override void updateBuffer(ref GraphicsBuffer buffer, in long offset, in ptrdiff_t size, in void* data) const nothrow
	{

	}

	public override Shader createShader(in string vertexSource, in string fragmentSource) const
	{
		throw new Exception("createShader not implemented for vulkan device.");
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