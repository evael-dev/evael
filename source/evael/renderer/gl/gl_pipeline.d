module evael.renderer.gl.gl_pipeline;

import evael.renderer.pipeline;
import evael.renderer.buffer;

import evael.renderer.gl.gl_shader;
import evael.renderer.gl.gl_wrapper;
import evael.renderer.gl.gl_uniform_resource;
import evael.renderer.gl.gl_texture_resource;

import evael.renderer.resources.resource;
import evael.renderer.texture;

import evael.lib.memory;

class GLPipeline : Pipeline
{
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