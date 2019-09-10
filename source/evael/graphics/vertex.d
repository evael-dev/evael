module evael.graphics.vertex;

import std.conv : to;

import evael.graphics.gl;

import evael.utils.math;
import evael.utils.color;

alias Vertex2PositionColor = VertexPositionColor!2;
alias Vertex2PositionColorTexture = VertexPositionColorTexture!2;
alias Vertex2PositionColorNormal = VertexPositionColorNormal!2;

alias Vertex3PositionColor = VertexPositionColor!3;
alias Vertex3PositionColorTexture = VertexPositionColorTexture!3;
alias Vertex3PositionColorNormal = VertexPositionColorNormal!3;

struct ShaderAttribute
{
	int layoutIndex;
	int type;
	int size;
	bool normalized;
}

struct VertexPositionColor(int positionCount)
{
	// Name in shader, type of data, count of data, normalized ?
	@ShaderAttribute(0, GLType.Float, positionCount, false)
	public Vector!(float, positionCount) position;
	
	@ShaderAttribute(1, GLType.UByte, 4, true)
	public Color color;
}

struct VertexPositionColorTexture(int positionCount)
{
	@ShaderAttribute(0, GLType.Float, positionCount, false)
	public Vector!(float, positionCount) position;

	@ShaderAttribute(1, GLType.UByte, 4, true)
	public Color color;

	@ShaderAttribute(2, GLType.Float, 2, false)
	public vec2 textureCoordinate;
}

struct VertexPositionColorNormal(int positionCount)
{
	@ShaderAttribute(0, GLType.Float, positionCount, false)
	public Vector!(float, positionCount) position;

	@ShaderAttribute(1, GLType.UByte, 4, true)
	public Color color;

	@ShaderAttribute(2, GLType.Float, 3, true)
	public vec3 normal;
}

struct VertexPositionColorNormalTexture
{
	@ShaderAttribute(0, GLType.Float, 3, false)
	public vec3 position;

	@ShaderAttribute(1, GLType.UByte, 4, true)
	public Color color;

	@ShaderAttribute(2, GLType.Float, 3, true)
	public vec3 normal;

	@ShaderAttribute(3, GLType.Float, 2, false)
	public vec2 textureCoordinate;
}

struct TerrainVertex
{
	@ShaderAttribute(0, GLType.Float, 3, false)
	public vec3 position;

	@ShaderAttribute(1, GLType.UByte, 4, true)
	public Color color;

	@ShaderAttribute(2, GLType.Float, 3, true)
	public vec3 normal;

	@ShaderAttribute(3, GLType.Float, 2, false)
	public vec2 textureCoordinate;

	@ShaderAttribute(4, GLType.Float, 3, true)
	public vec3 tangent;
	
	@ShaderAttribute(5, GLType.Float, 3, true)
	public vec3 bitangent;

	@ShaderAttribute(6, GLType.Float, 1, false)
	public float textureId;

	@ShaderAttribute(7, GLType.Float, 1, false)
	public float blendingTextureId;
}

struct IqmVertex
{
    @ShaderAttribute(0, GLType.Float, 3, false)
    public vec3 position;

    @ShaderAttribute(1, GLType.UByte, 4, true)
    public Color color;

    @ShaderAttribute(2, GLType.Float, 3, true)
    public vec3 normal;

    @ShaderAttribute(3, GLType.Float, 2, false)
    public vec2 textureCoordinate;

    @ShaderAttribute(4, GLType.UByte, 4, false)
    public ubvec4 blendIndex;

    @ShaderAttribute(5, GLType.UByte, 4, true)
    public ubvec4 blendWeight;
}

struct Instancing(int layoutIndex)
{
	@ShaderAttribute(layoutIndex, GLType.Float, 4, false)
    public vec4 row1;

    @ShaderAttribute(layoutIndex + 1, GLType.Float, 4, false)
    public vec4 row2;

    @ShaderAttribute(layoutIndex + 2, GLType.Float, 4, false)
    public vec4 row3;

    @ShaderAttribute(layoutIndex + 3, GLType.Float, 4, false)
    public vec4 row4;
}