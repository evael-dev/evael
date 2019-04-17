module evael.graphics.shapes.Circle;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.shaders.Shader;
import evael.graphics.Vertex;
import evael.graphics.Texture;

import evael.utils.Math;
import evael.utils.Color;
import evael.utils.Size;

/**
 * Circle.
 * Renders circle.
 */
class Circle : Drawable
{
	private uint m_divisions;
	private uint m_radius;

	/**
	 * Circle constructor.
	 * Params:
	 *		graphicsDevice : graphics device
	 *		divisions : circle divisions
	 *		radius : circle raddius
	 */
	@nogc @safe
	public this(GraphicsDevice graphicsDevice, in uint divisions, in uint radius) pure nothrow
	{
		super();

		this.m_graphicsDevice = graphicsDevice;

		// We need two additional points, both are origin
		this.m_divisions = divisions + 2;

		this.m_radius = radius;
	}

	/**
	 * Initializes circle.
	 * TODO: @nogc
	 */
	public void initialize() nothrow
	{
		import std.math;

		auto vertices = new VertexPositionColor!3[this.m_divisions];
		immutable color = Color(0, 130, 206, 160);
		immutable originPoint = VertexPositionColor!3(vec3(0, 2, 0), Color(0, 120, 180, 130));

		vertices[0] = originPoint;

		// 2 * PI, we can add / this.m_divisions
		auto circleRadians = 2 * PI / (this.m_divisions - 2);

		for(int i = 1; i < (this.m_divisions - 1); i++) 
		{ 
			vertices[i] = VertexPositionColor!3(
				vec3(this.m_radius * cos (i * circleRadians), 2, this.m_radius * sin (i * circleRadians)), color
			);
		}

		vertices[$ - 1] = vertices[1];

		this.m_vertexBuffer = this.m_graphicsDevice.createVertexBuffer(VertexPositionColor!3.sizeof * vertices.length, vertices.ptr);
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)
	{
		if (!this.m_isVisible)
			return;

		gl.DepthMask(false);

		this.m_graphicsDevice.enableShader(this.m_shader);

		//this.m_graphicsDevice.bindTexture(this.m_texture);

		mat4 model = translationMatrix(this.m_position);

		if(this.m_scale.x != 1.0f || this.m_scale.z != 1.0f)
		{
			model *= scaleMatrix(this.m_scale);
		}

		this.m_graphicsDevice.setMatrix(this.m_shader.modelMatrix, model.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

		this.m_graphicsDevice.setVertexBuffer!(VertexPositionColor!3)(this.m_vertexBuffer);
		this.m_graphicsDevice.drawPrimitives!(PrimitiveType.TriangleFan)(this.m_divisions);

		this.m_graphicsDevice.disableShader();

		gl.DepthMask(true);
	}

	public void draw(in float deltaTime)
	{
		this.draw(deltaTime, this.m_graphicsDevice.viewMatrix, this.m_graphicsDevice.projectionMatrix);
	}
}
