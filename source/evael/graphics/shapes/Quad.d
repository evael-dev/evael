module evael.graphics.shapes.Quad;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.shaders.Shader;
import evael.graphics.Vertex;
import evael.graphics.Texture;

import evael.utils.Math;
import evael.utils.Color;
import evael.utils.Size;

/**
 * Quad.
 * Renders indexed quad.
 */
class Quad(Type) : Drawable
{
	private Type[] m_vertices;
	private int[] m_indices;

	private uint m_trianglesNumber;

	/**
	 * Quad constructor.
	 * Params:
	 *		graphicsDevice : graphics device
	 *		vertices : quad vertices
	 *		indices : quad indices
	 */
	@nogc
	public this(GraphicsDevice graphicsDevice, Type[] vertices, int[] indices) nothrow
	{
		super(0, 0, 0);

		this.m_graphicsDevice = graphicsDevice;
		this.m_vertices = vertices;
		this.m_indices = indices;

		this.initialize();
	}

	/**
	 * Quad destructor.
	 */
	public void dispose()
	{

	}

	/**
	 * Initializes quad.
	 */
	@nogc
	public void initialize() nothrow
	{
		this.m_vao = this.m_graphicsDevice.generateVAO();
		this.m_vertexBuffer = this.m_graphicsDevice.createVertexBuffer(Type.sizeof * this.m_vertices.length, this.m_vertices.ptr);
		this.m_indexBuffer = this.m_graphicsDevice.createIndexBuffer(uint.sizeof * this.m_indices.length, this.m_indices.ptr);

		this.m_graphicsDevice.setVertexBuffer!(Type)(this.m_vertexBuffer);		

		this.m_graphicsDevice.bindVAO(0);

		this.m_trianglesNumber = cast(uint) this.m_indices.length / 3;
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)				
	{
		if (!this.m_isVisible)
			return;

		this.m_graphicsDevice.enableShader(this.m_shader);

		if (this.m_texture !is null)
		{
			this.m_graphicsDevice.bindTexture(this.m_texture);
		}

        mat4 translation = translationMatrix(this.m_position);
        mat4 rotation = this.m_rotation.toMatrix4x4();
		mat4 scale = scaleMatrix(this.m_scale);
        mat4 model = translation * rotation * scale;

		this.m_graphicsDevice.setMatrix(this.m_shader.modelMatrix, model.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

		this.m_graphicsDevice.bindVAO(this.m_vao);

		this.m_graphicsDevice.drawIndexedPrimitives!(PrimitiveType.Triangle)(this.m_trianglesNumber);

		this.m_graphicsDevice.bindVAO(0);

		this.m_graphicsDevice.disableShader();
	}

	public void draw(in float deltaTime)
	{
		this.draw(deltaTime, this.m_graphicsDevice.viewMatrix, this.m_graphicsDevice.projectionMatrix);
	}

	@nogc
	@property nothrow
	{
		public Type[] vertices()
		{
			return this.m_vertices;
		}

		public int[] indices()
		{
			return this.m_indices;
		}
	}
}
