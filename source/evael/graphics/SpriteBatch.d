module evael.graphics.SpriteBatch;

import evael.graphics.GL;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.Vertex;

import evael.utils.math;
import evael.utils.Color;

import dnogc.DynamicArray;
import dnogc.Utils;

/**
 * SpriteBatch
 * Draw batched quads.
 */
class SpriteBatch(VertexType) : Drawable
{
	/// Vertices list
	private DynamicArray!VertexType m_vertices;

	/// Indices list
	private DynamicArray!uint m_indices;

	/// Indicates if quads data has been sent to opengl
	private bool m_initialized;

	/// Tilesize
	private uint m_tileSize;

	/// Triangles number
	private uint m_trianglesNumber;

	/**
	 * SpriteBatch constructor.
	 */
	@nogc @safe
	public this(GraphicsDevice graphics) pure nothrow
	{
		super(graphics);
		this.m_initialized = false;
	}

	/**
	 * SpriteBatch destructor.
	 */
	public void dispose()
	{
		this.m_vertices.dispose();
		this.m_indices.dispose();
	}

	/**
	 * Initializes SpriteBatch.
	 */
	@nogc
	public void initialize() nothrow
	{
		this.m_vao = this.m_graphicsDevice.generateVAO();
		this.m_vertexBuffer = this.m_graphicsDevice.createVertexBuffer(VertexType.sizeof * this.m_vertices.length, this.m_vertices.ptr);
		this.m_indexBuffer = this.m_graphicsDevice.createIndexBuffer(uint.sizeof * this.m_indices.length, this.m_indices.ptr);

		this.m_graphicsDevice.setVertexBuffer!(VertexType)(this.m_vertexBuffer);		

		this.m_graphicsDevice.bindVAO(0);

		this.m_trianglesNumber = this.m_indices.length / 3;

		this.m_initialized = true;
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)				
	{
		if (!this.m_isVisible)
			return;

		this.m_graphicsDevice.enableShader(this.m_shader);

		if (this.m_texture !is null)
		{
			glActiveTexture(GL_TEXTURE0);
			this.m_graphicsDevice.bindTexture(this.m_texture);
		}

		mat4 translation = translationMatrix(this.m_position);
		mat4 rotation = this.m_rotation.toMatrix4x4();
		mat4 scale = scaleMatrix(this.m_scale);
		mat4 model = rotation * scale;

		this.m_graphicsDevice.setMatrix(this.m_shader.modelMatrix, model.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

		this.m_graphicsDevice.bindVAO(this.m_vao);
		this.m_graphicsDevice.drawIndexedPrimitives!(PrimitiveType.Triangle)(this.m_trianglesNumber);
		this.m_graphicsDevice.bindVAO(0);

		this.m_graphicsDevice.disableShader();
	}

	/**
	 * Add vertices in the batch.
	 * Params:
	 *       quad : quad
	 */
	@nogc
	public void addVertices(VertexType[] vertices, uint[] indices)
	{
		if (this.m_initialized)
		{
			debug dln("Trying to add a quad to an already initialized SpriteBatch.");
			return;
		}

		foreach (ref v; vertices)
		{
			this.m_vertices.insert(v);
		}

		foreach (i; indices)
		{
			this.m_indices.insert(i);
		}
	}

	static if (is(VertexType : Vertex2PositionColorTexture))
	{
		public void addQuad(in vec2 position, in ivec2 textureTilePosition)
		{
			immutable int tilePerWidth = this.m_texture.size.width / this.m_tileSize;
			immutable float v = 1.0f / tilePerWidth;

			import std.algorithm;
			import std.array;

			uint[] indices = [0, 1, 2, 2, 1, 3].map!(index => index + this.m_vertices.length).array;

			this.addVertices(
				[
					// Bottom-left vertex
					Vertex2PositionColorTexture(vec2(position.x, position.y), Color.White, vec2(textureTilePosition.x * v, (textureTilePosition.y + 1) * v)),
					// Top-left vertex
					Vertex2PositionColorTexture(vec2(position.x, position.y + this.m_tileSize), Color.White, vec2(textureTilePosition.x * v, textureTilePosition.y * v)),
					// Bottom-right vertex
					Vertex2PositionColorTexture(vec2(position.x + this.m_tileSize, position.y), Color.White, vec2((textureTilePosition.x + 1) * v, (textureTilePosition.y + 1) * v)),
					// Top-right vertex
					Vertex2PositionColorTexture(vec2(position.x + this.m_tileSize, position.y + this.m_tileSize), Color.White, vec2((textureTilePosition.x + 1) * v, textureTilePosition.y * v))
				],
				indices
			);
		}
	}

	@nogc @safe
	@property pure nothrow
	{
		public void tileSize(in uint value)
		{
			this.m_tileSize = value;
		}
	}
}