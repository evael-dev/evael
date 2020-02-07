module evael.renderer.vertex;

import std.conv : to;

import evael.renderer.shader : ShaderAttribute, Yes, No;
import evael.renderer.enums : AttributeType;

import evael.utils.math;
import evael.utils.color;

alias Vertex2PositionColor = VertexPositionColor!2;
alias Vertex2PositionColorTexture = VertexPositionColorTexture!2;
alias Vertex2PositionColorNormal = VertexPositionColorNormal!2;
alias Vertex3PositionColor = VertexPositionColor!3;
alias Vertex3PositionColorTexture = VertexPositionColorTexture!3;
alias Vertex3PositionColorNormal = VertexPositionColorNormal!3;

struct VertexPositionColor(int positionCount)
{
    @ShaderAttribute(0, AttributeType.Float, positionCount, No.normalized)
    public Vector!(float, positionCount) position;
    
    @ShaderAttribute(1, AttributeType.UByte, 4, Yes.normalized)
    public Color color;
}

struct VertexPositionColorTexture(int positionCount)
{
    @ShaderAttribute(0, AttributeType.Float, positionCount, No.normalized)
    public Vector!(float, positionCount) position;

    @ShaderAttribute(1, AttributeType.UByte, 4, Yes.normalized)
    public Color color;

    @ShaderAttribute(2, AttributeType.Float, 2, No.normalized)
    public vec2 textureCoordinate;
}

struct VertexPositionColorNormal(int positionCount)
{
    @ShaderAttribute(0, AttributeType.Float, positionCount, No.normalized)
    public Vector!(float, positionCount) position;

    @ShaderAttribute(1, AttributeType.UByte, 4, Yes.normalized)
    public Color color;

    @ShaderAttribute(2, AttributeType.Float, 3, Yes.normalized)
    public vec3 normal;
}

struct VertexPositionColorNormalTexture
{
    @ShaderAttribute(0, AttributeType.Float, 3, No.normalized)
    public vec3 position;

    @ShaderAttribute(1, AttributeType.UByte, 4, Yes.normalized)
    public Color color;

    @ShaderAttribute(2, AttributeType.Float, 3, Yes.normalized)
    public vec3 normal;

    @ShaderAttribute(3, AttributeType.Float, 2, No.normalized)
    public vec2 textureCoordinate;
}

struct TerrainVertex
{
    @ShaderAttribute(0, AttributeType.Float, 3, No.normalized)
    public vec3 position;

    @ShaderAttribute(1, AttributeType.UByte, 4, Yes.normalized)
    public Color color;

    @ShaderAttribute(2, AttributeType.Float, 3, Yes.normalized)
    public vec3 normal;

    @ShaderAttribute(3, AttributeType.Float, 2, No.normalized)
    public vec2 textureCoordinate;

    @ShaderAttribute(4, AttributeType.Float, 3, Yes.normalized)
    public vec3 tangent;
    
    @ShaderAttribute(5, AttributeType.Float, 3, Yes.normalized)
    public vec3 bitangent;

    @ShaderAttribute(6, AttributeType.Float, 1, No.normalized)
    public float textureId;

    @ShaderAttribute(7, AttributeType.Float, 1, No.normalized)
    public float blendingTextureId;
}

struct IqmVertex
{
    @ShaderAttribute(0, AttributeType.Float, 3, No.normalized)
    public vec3 position;

    @ShaderAttribute(1, AttributeType.UByte, 4, Yes.normalized)
    public Color color;

    @ShaderAttribute(2, AttributeType.Float, 3, Yes.normalized)
    public vec3 normal;

    @ShaderAttribute(3, AttributeType.Float, 2, No.normalized)
    public vec2 textureCoordinate;

    @ShaderAttribute(4, AttributeType.UByte, 4, No.normalized)
    public ubvec4 blendIndex;

    @ShaderAttribute(5, AttributeType.UByte, 4, Yes.normalized)
    public ubvec4 blendWeight;
}

struct Instancing(int layoutIndex)
{
    @ShaderAttribute(layoutIndex, AttributeType.Float, 4, No.normalized)
    public vec4 row1;

    @ShaderAttribute(layoutIndex + 1, AttributeType.Float, 4, No.normalized)
    public vec4 row2;

    @ShaderAttribute(layoutIndex + 2, AttributeType.Float, 4, No.normalized)
    public vec4 row3;

    @ShaderAttribute(layoutIndex + 3, AttributeType.Float, 4, No.normalized)
    public vec4 row4;
}