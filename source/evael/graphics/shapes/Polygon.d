module evael.graphics.shapes.Polygon;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.shaders.Shader;
import evael.graphics.Vertex;
import evael.graphics.Texture;

import evael.utils.Math;
import evael.utils.Color;
import evael.utils.Size;

/**
 * Polygon.
 */
class Polygon : Drawable
{
	private VertexPositionColor!3[] m_vertices;

	/**
	 * Polygon constructor.
	 * Params:
	 *		graphicsDevice : graphics device
	 */
	@nogc @safe
	public this()(GraphicsDevice graphicsDevice) pure nothrow
	{
		super(0, 0, 0, Size!int(0, 0));

		this.m_graphicsDevice = graphicsDevice;
	}

	/**
	 * Initializes polygon.
	 */
	public void initialize()
	{
		this.m_vertexBuffer = this.m_graphicsDevice.createVertexBuffer(VertexPositionColor!3.sizeof * this.m_vertices.length, this.m_vertices.ptr);
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)					
	{
		if (!this.m_isVisible)
			return;

		this.m_graphicsDevice.enableShader(this.m_shader);

		this.m_graphicsDevice.setMatrix(this.m_shader.modelMatrix, mat4.identity.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

		this.m_graphicsDevice.setVertexBuffer!(VertexPositionColor!3)(this.m_vertexBuffer);

		this.m_graphicsDevice.drawPrimitives!(PrimitiveType.TriangleFan)(cast(int) this.m_vertices.length);

		this.m_graphicsDevice.disableShader();
	}

	public void draw(in float deltaTime)
	{
		this.draw(deltaTime, this.m_graphicsDevice.viewMatrix, this.m_graphicsDevice.projectionMatrix);
	}

	@nogc @safe
	@property pure nothrow
	{
		public void vertices(VertexPositionColor!3[] value) 
		{
			this.m_vertices = value;
		}

		public ref VertexPositionColor!3[] vertices() 
		{
			return vertices;
		}
	}
}
