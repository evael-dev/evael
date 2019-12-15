module evael.renderer.gl.gl_graphics_device;

import evael.renderer.graphics_device;
import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_enum_converter;
import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_texture;

import evael.lib.image.image;
import evael.lib.memory;
import evael.lib.containers.array;

class GLGraphicsDevice : GraphicsDevice
{
	private Array!GraphicsBuffer m_buffers;

	private uint m_vao;

	/**
	 * GLGraphicsDevice constructor.
	 */
	@nogc
	public this()
	{
		this.initialize();
	}

	/**
	 * GLGraphicsDevice destructor.
	 */
	@nogc
	public ~this()
	{
		foreach (buffer; this.m_buffers)
			gl.DeleteBuffers(1, &buffer.id);

		this.m_buffers.dispose();
	}
	
	@nogc
	private void initialize()
	{
		gl.GenVertexArrays(1, &this.m_vao);
		gl.BindVertexArray(this.m_vao);
	}

	@nogc
	public override void beginFrame(in Color color = Color.LightGrey)
	{
		auto colorf = color.asFloat();

		gl.Clear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		gl.ClearColor(colorf[0], colorf[1], colorf[2], 1.0f); 
	}

	@nogc
	public override void endFrame()
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
	public override GraphicsBuffer createBuffer(BufferType type, in ptrdiff_t size = 0, in void* data = null) nothrow
	{		
		auto buffer = this.generateBuffer(type);

		if (size > 0)
			this.allocateBuffer(buffer, size, data);

		return buffer;
	}

	/**
	 * Deletes a buffer object.
	 * Params:
	 *		buffer : buffer
	 */
	@nogc
	public override void deleteBuffer(in GraphicsBuffer bufferToDelete)
	{
		gl.DeleteBuffers(1, &bufferToDelete.id);

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
		gl.BindBuffer(buffer.type, buffer.id);

		if (buffer.size == 0)
		{
			this.allocateBuffer(buffer, size, data);
		}
		else 
		{
			assert(offset + size <= buffer.size, "Updating buffer with invalid offset/size.");
			gl.BufferSubData(buffer.type, offset, size, data);
		}
	}

	/**
	 * Generates a buffer object.
	 * Params:
	 *		type : buffer object type
	 */
	@nogc
	private GraphicsBuffer generateBuffer(in BufferType type) nothrow
	{
		immutable glBufferType = GLEnumConverter.bufferType(type);

		uint id;
		gl.GenBuffers(1, &id);
		gl.BindBuffer(glBufferType, id);

		GraphicsBuffer buffer = 
		{
			id: id,
			type: glBufferType
		};

		this.m_buffers.insert(buffer);

		return buffer;
	}

	@nogc
	private void allocateBuffer(ref GraphicsBuffer buffer, ptrdiff_t size, in void* data) const nothrow
	{
		gl.BufferData(buffer.type, size, data, GL_DYNAMIC_DRAW);
		buffer.size = size;
	}
} 