module evael.renderer.gl.gl_enum_converter;

import evael.renderer.enums;
import bindbc.opengl;

static class GLEnumConverter
{
    @nogc
    public static GLenum bufferType(BufferType type) nothrow
    {
        final switch(type)
        {
            case BufferType.Vertex: return GL_ARRAY_BUFFER;
            case BufferType.Index: return GL_ELEMENT_ARRAY_BUFFER;
        }
    }

    @nogc
    public static GLenum shaderType(ShaderType type) nothrow
    {
        final switch(type)
        {
            case ShaderType.Vertex: return GL_VERTEX_SHADER;
            case ShaderType.Fragment: return GL_FRAGMENT_SHADER;
            case ShaderType.Geometry: return GL_GEOMETRY_SHADER;
        }
    }
}