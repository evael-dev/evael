module evael.renderer.vk.vk_buffer;

import evael.renderer.vk.vk_wrapper;
import evael.renderer.vk.vk_enum_converter;

import evael.renderer.buffer;
import evael.renderer.enums.buffer_type;

alias VertexBuffer = VulkanBuffer!(BufferType.Vertex);
alias IndexBuffer = VulkanBuffer!(BufferType.Index);
alias UniformBuffer = VulkanBuffer!(BufferType.Uniform);
	
class VulkanBuffer(BufferType type) : Buffer!type
{
	/**
	 * GLBuffer constructor.
	 */
	@nogc
	public this(in size_t size, void* data = null)
	{
		super(size);
		
		this.m_internalType = VulkanEnumConverter.bufferType(type);
	}

	/**
	 * GLBuffer destructor.
	 */
	@nogc
	public ~this()
	{
	}

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public override void update(in long offset, in ptrdiff_t size, in void* data) const nothrow
	{
		assert(offset + size <= this.m_size, "Updating buffer with invalid offset/size.");
	}
}


