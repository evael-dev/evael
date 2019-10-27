module evael.renderer.graphics_device_factory;

import evael.renderer.gl.gl_graphics_device;

import evael.lib.memory;

public 
{
    import evael.renderer.graphics_device;
    import evael.renderer.renderer_type;
}

static class GraphicsDeviceFactory
{
    @nogc
    public static GraphicsDevice createfromRendererType(in RendererType rendererType)
    {
        final switch(rendererType)
        {
            case RendererType.OpenGL: return MemoryHelper.create!GLGraphicsDevice();
            case RendererType.Vulkan: return null;
        }
    }
}