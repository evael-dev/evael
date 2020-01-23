module evael.renderer.gl.gl_buffer;

import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_enum_converter;

import evael.renderer.graphics_buffer;
import evael.renderer.enums.buffer_type;

alias VertexBuffer = GLBuffer!(BufferType.Vertex);
alias IndexBuffer = GLBuffer!(BufferType.Index);
alias UniformBuffer = GLBuffer!(BufferType.Uniform);
	
class GLBuffer(BufferType type, uint usage = GL_DYNAMIC_DRAW) : GraphicsBuffer!type
{
	/**
	 * GLBuffer constructor.
	 */
	@nogc
	public this(in size_t size, void* data = null)
	{
		super(size);
		
		this.m_internalType = GLEnumConverter.bufferType(type);

		gl.GenBuffers(1, &this.m_id);
		gl.BindBuffer(this.m_internalType, this.m_id);
		gl.BufferData(this.m_internalType, size, data, usage);
	}

	/**
	 * GLBuffer destructor.
	 */
	@nogc
	public ~this()
	{
		gl.DeleteBuffers(1, &this.m_id);
	}

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public override void update(in ptrdiff_t offset, in ptrdiff_t size, in void* data) const nothrow
	{
		assert(offset + size <= this.m_size, "Updating buffer with invalid offset/size.");

		gl.BindBuffer(this.m_internalType, this.m_id);
		gl.BufferSubData(this.m_internalType, offset, size, data);
	}
}


