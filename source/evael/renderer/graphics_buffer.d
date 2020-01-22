module evael.renderer.graphics_buffer;

import evael.renderer.enums.buffer_type;

import evael.lib.memory;

alias VertexBuffer = GraphicsBuffer!(BufferType.Vertex);
alias IndexBuffer = GraphicsBuffer!(BufferType.Index);
alias UniformBuffer = GraphicsBuffer!(BufferType.Uniform);

abstract class GraphicsBuffer(BufferType t) : NoGCClass
{
	protected BufferType m_type = t;
	protected uint m_internalType;
	
	protected uint m_id;
	protected string m_name;
	protected size_t m_size;

	/*
	 * Buffer constructor.
	 */
	@nogc
	public this(in size_t size)
	{
		this.m_size = size;
	}

	/*
	 * Buffer destructor.
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
	public abstract void update(in long offset, in ptrdiff_t size, in void* data) const nothrow;

	@nogc
	@property nothrow
	{
		public BufferType type() const
		{
			return this.m_type;
		}
		
		public uint internalType() const
		{
			return this.m_internalType;
		}

		public uint id() const
		{
			return this.m_id;
		}

		public string name() const
		{
			return this.m_name;
		}

		public size_t size() const
		{
			return this.m_size;
		}
	}
}