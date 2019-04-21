module evael.graphics.shapes.Triangle;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.shaders.Shader;
import evael.graphics.Vertex;
import evael.graphics.Texture;

import evael.utils.math;
import evael.utils.Color;

/**
 * Triangle.
 * Renders a triangle.
 */
class Triangle : Drawable
{
	public this()(GraphicsDevice graphicsDevice)
	{
		super(graphicsDevice);
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)
	{
		if(!this.m_isVisible)
			return;

		this.m_graphicsDevice.enableShader(this.m_shader);

		this.m_graphicsDevice.setMatrix(this.m_shader.modelMatrix, mat4.identity.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

		this.m_graphicsDevice.setVertexBuffer!(VertexPositionColor!3)(this.m_vertexBuffer);

		this.m_graphicsDevice.drawPrimitives!(PrimitiveType.Triangle)(1);

		this.m_graphicsDevice.disableShader();
	}

	public void draw(in float deltaTime)
	{
		this.draw(deltaTime, this.m_graphicsDevice.viewMatrix, this.m_graphicsDevice.projectionMatrix);
	}
}
