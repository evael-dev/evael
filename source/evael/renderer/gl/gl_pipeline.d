module evael.renderer.gl.gl_pipeline;

import evael.renderer.pipeline;
import evael.renderer.graphics_buffer;

import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_uniform_resource;
import evael.renderer.gl.gl_texture_resource;
import evael.renderer.gl.gl_enum_converter;

import evael.renderer.resources.resource;
import evael.renderer.texture;

import evael.lib.memory;

class GLPipeline : Pipeline
{
    @nogc
    public override void apply() const nothrow
    {
        if (this.depthState.enabled)
        {
            gl.Enable(GL_DEPTH_TEST);
            gl.DepthMask(!this.depthState.readOnly);
        }
        
        if (this.blendState.enabled)
        {
            gl.Enable(GL_BLEND);
            gl.BlendFuncSeparate(
                GLEnumConverter.blendFactor(this.blendState.sourceRGB),
                GLEnumConverter.blendFactor(this.blendState.destinationRGB),
                GLEnumConverter.blendFactor(this.blendState.sourceAlpha),
                GLEnumConverter.blendFactor(this.blendState.destinationAlpha)
            );

            gl.BlendEquationSeparate(
                GLEnumConverter.blendFunction(this.blendState.colorFunction),
                GLEnumConverter.blendFunction(this.blendState.alphaFunction)
            );
        }

        foreach (resource; this.m_resources)
        {
            resource.apply();
        }
    }

    @nogc
    public override void clear() const nothrow
    {
        foreach (resource; this.m_resources)
        {
            resource.clear();
        }

        if (this.blendState.enabled)
        {
            gl.Disable(GL_BLEND);
        }

        if (this.depthState.enabled)
        {
            gl.Disable(GL_DEPTH_TEST);
        }
    }

    @nogc
    public override GLTextureResource addTextureResource(Texture texture = null)
    {
        auto resource = MemoryHelper.create!GLTextureResource(texture);
        this.m_resources.insert(resource);
        return resource;
    }

    @nogc
    public GLUniformResource!T addUniformResource(T)(in string name, T value)
    {
        assert(this.shader !is null, "Set a shader before adding an uniform resource.");

        auto resource = MemoryHelper.create!(GLUniformResource!T)(name, (cast(GLShader) this.shader).programId, value);
        this.m_resources.insert(resource);
        return resource;
    }
}