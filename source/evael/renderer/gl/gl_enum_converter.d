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
            case BufferType.Vertex:  return GL_ARRAY_BUFFER;
            case BufferType.Index:   return GL_ELEMENT_ARRAY_BUFFER;
            case BufferType.Uniform: return GL_UNIFORM_BUFFER;
        }
    }

    @nogc
    public static GLenum shaderType(ShaderType type) nothrow
    {
        final switch(type)
        {
            case ShaderType.Vertex:   return GL_VERTEX_SHADER;
            case ShaderType.Fragment: return GL_FRAGMENT_SHADER;
            case ShaderType.Geometry: return GL_GEOMETRY_SHADER;
        }
    }

    @nogc
    public static GLenum attributeType(AttributeType type) nothrow
    {
        final switch(type)
        {
            case AttributeType.Float: return GL_FLOAT;
            case AttributeType.UByte: return GL_UNSIGNED_BYTE;
        }
    }

    @nogc
    public static GLenum blendFactor(BlendFactor blendFactor) nothrow
    {
        final switch(blendFactor)
        {
            case BlendFactor.Zero                    : return GL_ZERO;
            case BlendFactor.One                     : return GL_ONE;
            case BlendFactor.SourceColor             : return GL_SRC_COLOR;
            case BlendFactor.InverseSourceColor      : return GL_ONE_MINUS_SRC_COLOR;
            case BlendFactor.DestinationColor        : return GL_DST_COLOR;
            case BlendFactor.InverseDestinationColor : return GL_ONE_MINUS_DST_COLOR;
            case BlendFactor.SourceAlpha             : return GL_SRC_ALPHA;
            case BlendFactor.InverseSourceAlpha      : return GL_ONE_MINUS_SRC_ALPHA;
            case BlendFactor.DestinationAlpha        : return GL_DST_ALPHA;
            case BlendFactor.InverseDestinationAlpha : return GL_ONE_MINUS_DST_ALPHA;
        }
    }

    @nogc
    public static GLenum blendFunction(BlendFunction blendFunction) nothrow
    {
        final switch(blendFunction)
        {
            case BlendFunction.Add             : return GL_FUNC_ADD;
            case BlendFunction.Subtract        : return GL_FUNC_SUBTRACT;
            case BlendFunction.ReverseSubtract : return GL_FUNC_REVERSE_SUBTRACT;
            case BlendFunction.Minimum         : return GL_MIN;
            case BlendFunction.Maximum         : return GL_MAX;
        }
    }
}