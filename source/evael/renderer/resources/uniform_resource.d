module evael.renderer.resources.uniform_resource;

import evael.renderer.resources.resource;
import evael.renderer.enums.resource_type;
import evael.renderer.graphics_buffer;

import evael.lib.memory : MemoryHelper;

abstract class UniformResource(T) : Resource
{
    protected T m_uniformStruct;

    /// Uniform name in shader
    protected string m_name;

    /// Uniform buffer
    protected UniformBuffer m_buffer;
    
    @nogc
    public this(in string name)
    {
        super(ResourceType.UniformBuffer);

        this.m_name = name;
    }

    @nogc
    public ~this()
    {
        MemoryHelper.dispose(this.m_buffer);
    }

    @nogc
    public auto opDispatch(string key)()
    {
        return mixin("this.m_uniformStruct." ~ key);
    }

    @nogc
    public void opDispatch(string key, T)(auto ref inout(T) value)
    {
        mixin("this.m_uniformStruct." ~ key) = value;
    }

    @nogc
    public abstract void update() const nothrow;

    @nogc
    @property nothrow
    {
        public void value()(in auto ref T value)
        {
            this.m_uniformStruct = value;
        }
        
        public string name() const
        {
            return this.m_name;
        }

        public UniformBuffer buffer()
        {
            return this.m_buffer;
        }
    }
}