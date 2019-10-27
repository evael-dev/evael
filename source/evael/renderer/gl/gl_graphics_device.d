module evael.renderer.gl.gl_graphics_device;

import evael.renderer.graphics_device;
import evael.renderer.gl.gl_command;

import evael.graphics.gl;

import evael.lib.memory;
import evael.lib.containers.array;

class GLGraphicsDevice : GraphicsDevice
{
	private Array!GraphicsBuffer m_buffers;

	/**
	 * GLGraphicsDevice constructor.
	 */
	@nogc
	public this()
	{
	}

	/**
	 * GLGraphicsDevice destructor.
	 */
	@nogc
	public ~this()
	{
		foreach (buffer; this.m_buffers)
		{
			gl.DeleteBuffers(1, &buffer.id);
		}

		this.m_buffers.dispose();
	}
	
	@nogc
	public override GraphicsCommand createCommand()
	{
		return MemoryHelper.create!GLCommand();
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
		auto buffer = this.generateBuffer(GL_ARRAY_BUFFER);
		gl.BufferData(GL_ARRAY_BUFFER, size, data, usage);

		return buffer;
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
		auto buffer = this.generateBuffer(GL_ELEMENT_ARRAY_BUFFER);
		gl.BufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, usage);

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
	public override void updateBuffer(in GraphicsBuffer buffer, in long offset, in ptrdiff_t size, in void* data) const nothrow
	{
		gl.BindBuffer(buffer.type, buffer.id);
		gl.BufferSubData(buffer.type, offset, size, data);
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
		gl.GenBuffers(1, &id);
		gl.BindBuffer(type, id);

		GraphicsBuffer buffer = {
			id: id,
			type: type
		};

		this.m_buffers.insert(buffer);

		return buffer;
	}
} 