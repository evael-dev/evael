module evael.renderer;

public
{
    version(GL_RENDERER)
    {
        import evael.renderer.gl;
    }

    import evael.renderer.graphics_pipeline;
    import evael.renderer.enums;
}