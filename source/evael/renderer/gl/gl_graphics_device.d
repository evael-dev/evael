module evael.renderer.gl.gl_graphics_device;

import evael.renderer.buffer;
import evael.renderer.graphics_device;
import evael.renderer.graphics_command;

import evael.renderer.gl.gl_command;

import evael.graphics.gl;

import evael.lib.memory;
import evael.lib.containers.array;

class GLGraphicsDevice : GraphicsDevice
{
	private Array!uint m_buffers;

	/**
	 * GLGraphicsDevice constructor.
	 */
	public this()
	{
	}

	/**
	 * GLGraphicsDevice destructor.
	 */
	public ~this()
	{
		foreach (id; this.m_buffers)
		{
			gl.DeleteBuffers(1, &id);
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
	public override uint createVertexBuffer(in ptrdiff_t size, in void* data, in uint usage) nothrow
	{
		immutable uint id = this.generateBuffer(GL_ARRAY_BUFFER);
		gl.BufferData(GL_ARRAY_BUFFER, size, data, usage);

		return id;
	}

	/**
	 * Creates an index buffer object.
	 * Params:
	 *		size : buffer object size
	 *		data : data to send
	 *		usage : usage type
	 */
	@nogc
	public override uint createIndexBuffer(in GLsizeiptr size, in void* data, in uint usage) nothrow
	{
		immutable uint id = this.generateBuffer(GL_ELEMENT_ARRAY_BUFFER);
		gl.BufferData(GL_ELEMENT_ARRAY_BUFFER, size, data, usage);

		return id;
	}

	/**
	 * Deletes a buffer object.
	 * Params:
	 *		id : buffer id
	 */
	@nogc
	public override void deleteBuffer(in uint id) nothrow
	{
		gl.DeleteBuffers(1, &id);

		foreach (i, bufferId; this.m_buffers)
		{
			if(bufferId == id)
			{
				this.m_buffers.removeAt(i);
				break;
			}
		}
	}

	/**
	 * Updates a subset of a buffer object's data store.
	 * Params:
	 *		 id : buffer object
	 *		 offet : offset into the buffer object's data store where data replacement will begin, measured in bytes
	 *		 size : size in bytes of the data store region being replaced
	 *		 data : pointer to the new data that will be copied into the data store
	 */
	@nogc
	public override void updateBuffer(in uint id, in long offset, in ptrdiff_t size, in void* data) const nothrow
	{
		gl.BindBuffer(target, id);
		gl.BufferSubData(target, offset, size, data);
	}

	/**
	 * Generates a buffer object.
	 * Params:
	 *		type : buffer object type
	 */
	@nogc
    private uint generateBuffer(in uint type) nothrow
	{
		uint id;
		gl.GenBuffers(1, &id);
		gl.BindBuffer(type, id);

		this.m_buffers.insert(id);

		return id;
	}
} 