module evael.renderer;

public
{
    version(GL_RENDERER)
    {
        import evael.renderer.gl;
    }

    import evael.renderer.enums;
    import evael.renderer.graphics_pipeline;
    import evael.renderer.blend_state;

    import std.typecons : Yes, No;
}