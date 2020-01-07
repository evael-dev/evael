module evael.renderer.resources.resource;

import evael.renderer.enums.resource_type;

import evael.lib.memory.no_gc_class;

/**
 * Represents a shader resource (Texture or UniformBuffer).
 */
abstract class Resource : NoGCClass
{
	private ResourceType m_type;

	@nogc
	public this(in ResourceType type)
	{
		this.m_type = type;
	}

	@nogc
	public abstract void apply() const nothrow;

	@nogc
	public abstract void clear() const nothrow;

	@nogc
	@property nothrow
	public ResourceType type() const
	{
		return this.m_type;
	}
}