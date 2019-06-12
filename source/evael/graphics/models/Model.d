module evael.graphics.models.Model;

import evael.system.Asset;

import evael.graphics.Drawable;
import evael.graphics.models.BoundingBox;
import evael.graphics.GraphicsDevice;
import evael.graphics.Vertex;
import evael.graphics.shaders.Shader;

import evael.utils.Math;

/**
 * Model.
 */
class Model : Drawable, IAsset
{
	/// Buffer for instancing
	protected uint[] m_instancingBuffers;

	/// Instances count
	protected uint m_instancesCount;

	/// Shader
	protected Shader m_shader;

	/**
	 * Model constructor.
	 */
	@nogc
	public this(GraphicsDevice graphicsDevice) nothrow
	{
		super(graphicsDevice);

		this.m_vao = this.m_graphicsDevice.generateVAO();		
	}

	/**
	 * Model destructor.
	 */
	public void dispose()
	{
		
	}

	/**
	 * Initializes instancing data.
	 * Params:
	 *		instancesCount : instances count for the next draw call
	 *		buffersCount : vbos count to generate for instances data
	 */
	public void initializeInstancing(in uint instancesCount, in int buffersCount) nothrow
	{
		if(this.m_instancingBuffers == null)
		{
			this.m_instancingBuffers = this.m_graphicsDevice.generateBuffers(BufferType.VertexBuffer, buffersCount);
		}

		this.m_instancesCount = instancesCount;
	}

	/**
	 * Sets buffer data for buffer at position index.
	 * Params:
	 *		index : buffer index
	 *		data : data to send
	 */
	@nogc
	public void setInstancingBufferData(T)(in int index, void* data) nothrow
	{
		assert(index < this.m_instancingBuffers.length, "Invalid instancing buffer index");

		this.m_graphicsDevice.allocData!(BufferType.VertexBuffer)(
			this.m_instancingBuffers[index], this.m_instancesCount * T.sizeof, data, BufferUsage.DynamicDraw
		);
	}

	/**
	 * Updates buffer data for buffer at position index.
	 * Params:
	 *		index : buffer index
	 *		offset : offset in the buffer
	 *		data : data to send
	 */
	@nogc
	public void updateInstancingBufferData(in int index, in GLintptr offset, in GLsizeiptr size, void* data) nothrow
	{
		assert(index < this.m_instancingBuffers.length, "Invalid instancing buffer index");

		this.m_graphicsDevice.sendVertexBufferData(this.m_instancingBuffers[index], offset, size, data);
	}


	public uint getInstancingBuffer(in int index)
	{
		assert(index < this.m_instancingBuffers.length, "Invalid instancing buffer index");
		
		return this.m_instancingBuffers[index];
	}

	/**
	 * Draws all instances, depends on model impl
	 */
	abstract public void drawInstances(in bool bindTexture = true);

	@nogc 
	@property nothrow
	{
		public uint vao()
		{
			return this.m_vao;
		}

		public uint instancesCount()
		{
			return this.m_instancesCount;
		}

		public bool availableInstances()
		{
			return this.m_instancesCount > 0;
		}
	}
}