module evael.renderer.gl.gl_uniform_resource;

import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_buffer;

import evael.renderer.resources.uniform_resource;

import evael.lib.memory : MemoryHelper;

private uint bindingPointIndex;

class GLUniformResource(T) : UniformResource!T
{   
	private uint m_blockIndex;
	private uint m_bindingPointIndex;

	/**
	 * GLUniformResource constructor.
	 */
	@nogc
	public this(in string name, in uint programId, T defaultValue)
	{
		super(name);

		assert(this.m_blockIndex != GL_INVALID_INDEX);

		this.m_buffer = MemoryHelper.create!UniformBuffer(T.sizeof, &defaultValue);
		this.m_blockIndex = gl.GetUniformBlockIndex(programId, cast(char*) this.m_name.ptr);
		this.m_bindingPointIndex = bindingPointIndex++;
		
		gl.BindBufferBase(GL_UNIFORM_BUFFER, this.m_bindingPointIndex, this.m_buffer.id);
		gl.UniformBlockBinding(programId, this.m_blockIndex, this.m_bindingPointIndex);

		gl.BindBuffer(GL_UNIFORM_BUFFER, 0);
	}

	@nogc
	public override void apply() const nothrow
	{
	}

	@nogc
	public override void clear() const nothrow
	{
	}

	@nogc
	public override void update() const nothrow
	{
		this.m_buffer.update(0, T.sizeof, &this.m_uniformStruct);
	}

	@nogc
	@property nothrow
	{
		public uint blockIndex() const
		{
			return this.m_blockIndex;
		}
	}
}

