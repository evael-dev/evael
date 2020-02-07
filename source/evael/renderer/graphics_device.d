module evael.renderer.graphics_device;

import evael.lib.memory.no_gc_class;

public 
{
    import evael.core.game_config : GraphicsSettings;

    import bindbc.glfw : GLFWwindow;

    import evael.renderer.graphics_buffer;
    import evael.renderer.graphics_command;
    import evael.renderer.shader;
    import evael.renderer.texture;

    import evael.renderer.enums.buffer_type;

    import evael.utils.color;
}

abstract class GraphicsDevice : NoGCClass
{
    protected GraphicsSettings m_graphicsSettings;

    protected GLFWwindow* m_window;

    /**
     * Device constructor.
     */
    @nogc
    public this(in ref GraphicsSettings graphicsSettings)
    {
        this.m_graphicsSettings = graphicsSettings;
    }

    /**
     * Device destructor.
     */
    @nogc
    public ~this()
    {

    }

    @nogc
    public abstract void beginFrame(in Color color = Color.Blue);

    @nogc
    public abstract void endFrame();

    @nogc
    @property
    public void window(GLFWwindow* win)
    {
        this.m_window = win;
    }
}