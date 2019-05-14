module evael.graphics.models.Wavefront;

import std.stdio;
import std.array : split;
import std.algorithm;
import std.string : indexOf;
import std.conv : to;

import dnogc.DynamicArray;

import evael.graphics.Drawable;
import evael.graphics.GraphicsDevice;
import evael.graphics.shaders.BasicLightShader;
import evael.graphics.Vertex;
import evael.graphics.Texture;
import evael.graphics.models.Model;
import evael.graphics.models.BoundingBox;

import evael.system.Asset;
import evael.system.AssetLoader;

import evael.utils.Math;
import evael.utils.Color;

class Wavefront	: Model
{
	enum MaterialType : ubyte
	{
		Texture,
		Color
	}

	struct Material
	{
		public MaterialType type;
		public Color color;
		public Texture texture;
	}

	/// Current bb
	private BoundingBox m_currentBoundingBox;

	private uint m_vertexBuffer, m_indexBuffer;

	private Texture m_texture;

	/// Triangles number
	private int m_trianglesNumber;

	private PolygonDefinition m_navPolygon;

	public this(GraphicsDevice graphicsDevice)
	{
		super(graphicsDevice);
	}

	public override void dispose()
	{
		this.m_navPolygon.dispose();
	}

	public override void drawInstances(in bool bindTexture = true)
	{
		if (this.m_instancesCount != 0)
		{
			if (bindTexture && this.m_texture !is null)
			{
				this.m_graphicsDevice.bindTexture(this.m_texture);
			}

			this.m_graphicsDevice.bindVAO(this.m_vao);

			gl.DrawArraysInstanced(GL_TRIANGLES, 0, this.m_trianglesNumber * 3, this.m_instancesCount);

			this.m_graphicsDevice.bindVAO(0);
		}
	}

	public override void draw(in float deltaTime, mat4 view, mat4 projection)
	{
		this.m_graphicsDevice.enableShader(this.m_shader);

		if (this.m_texture !is null)
		{
			this.m_graphicsDevice.bindTexture(this.m_texture);
		}

		mat4 translation = translationMatrix(this.m_position);
		mat4 rotation = this.m_rotation.toMatrix4x4();
		mat4 model = translation * rotation;
	
		this.m_graphicsDevice.setMatrix(this.m_shader.modelMatrix, model.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.viewMatrix, view.arrayof.ptr);
		this.m_graphicsDevice.setMatrix(this.m_shader.projectionMatrix, projection.arrayof.ptr);

		this.m_graphicsDevice.setEnvironment();

		this.m_graphicsDevice.bindVAO(this.m_vao);
		this.m_graphicsDevice.drawPrimitives!(PrimitiveType.Triangle)(this.m_trianglesNumber);
		this.m_graphicsDevice.bindVAO(0);

		this.m_graphicsDevice.clearTexture();

		this.m_graphicsDevice.disableShader();
	}

	static Wavefront load(in string fileName)
	{
		import evael.utils.Config;

		File file = File(Config.Paths.models!string ~ fileName);
		scope(exit) file.close;

		vec3[] vertices;
		vec3[] normals;
		vec2[] uvs;

		uint[] indices;
		uint[] uvsIndices;
		uint[] normalsIndices;

		Material defaultMaterial = Material(MaterialType.Color, Color.White, null);
		Material currentMaterial = defaultMaterial;

		auto materials = loadMaterials(Config.Paths.models!string ~ fileName[0 .. $ - 3] ~ "mtl");

		Texture texture;

		while (!file.eof())
		{
			string lineHeader = file.readln();

			if (lineHeader.length == 0)
				break;

			immutable string[] lineData = lineHeader.split();

			if (lineHeader.startsWith("v "))
			{
				vertices ~= vec3(lineData[1].to!float(), lineData[2].to!float(), lineData[3].to!float());
			}
			else if (lineHeader.startsWith("vt"))
			{
				uvs ~= vec2(lineData[1].to!float(), lineData[2].to!float());
			}
			else if (lineHeader.startsWith("vn"))
			{
				normals ~= vec3(lineData[1].to!float(), lineData[2].to!float(), lineData[3].to!float());
			}
			else if (lineHeader.startsWith("f"))
			{
				immutable string[] faceOne = lineData[1].split('/');
				immutable string[] faceTwo = lineData[2].split('/');
				immutable string[] faceThree = lineData[3].split('/');

				// Indice start at 1 in obj format
				indices ~= [faceOne[0].to!uint()  - 1, faceTwo[0].to!uint() - 1, faceThree[0].to!uint() - 1];

				if (uvs.length)
				{
					uvsIndices ~= [faceOne[1].to!uint()  - 1, faceTwo[1].to!uint() - 1, faceThree[1].to!uint() - 1];
				}

				if (normals.length)
				{
					normalsIndices ~= [faceOne[2].to!uint()  - 1, faceTwo[2].to!uint() - 1, faceThree[2].to!uint() - 1];
				}
			}
			else if (lineHeader.startsWith("usemtl"))
			{
				currentMaterial = materials.require(lineData[1], defaultMaterial);
				texture = currentMaterial.texture;
			}
		}

		auto outVertices = new VertexPositionColorNormalTexture[indices.length];

		foreach (i, indice; indices)
		{
			vec2 uv = vec2(1);
			vec3 normal = vec3(1, 0, 0);

			if (uvsIndices.length)
			{
				uv = uvs[uvsIndices[i]];
			}

			if (normalsIndices.length)
			{
				normal = normals[normalsIndices[i]];
			}

			outVertices[i] = VertexPositionColorNormalTexture(vertices[indices[i]], currentMaterial.color, normal, uv);
		}

		auto graphicsDevice = GraphicsDevice.getInstance();

		auto obj = new Wavefront(graphicsDevice);
		obj.m_texture = texture;
		obj.m_trianglesNumber = outVertices.length / 3;
		obj.m_vertexBuffer = graphicsDevice.createVertexBuffer(VertexPositionColorNormalTexture.sizeof * outVertices.length, outVertices.ptr);
		//obj.m_indexBuffer = graphicsDevice.createIndexBuffer(uint.sizeof * indices.length, indices.ptr);
		obj.m_shader = AssetLoader.getInstance().load!(BasicLightShader)("textured_primitive_light");

		graphicsDevice.setVertexBuffer!VertexPositionColorNormalTexture(obj.m_vertexBuffer);
		graphicsDevice.bindVAO(0);

		/* BoundingBox */
		auto minX = minCount!("a.x < b.x")(vertices)[0];
		auto minY = minCount!("a.y < b.y")(vertices)[0];
		auto minZ = minCount!("a.z < b.z")(vertices)[0];

		auto maxX = minCount!("a.x > b.x")(vertices)[0];
		auto maxY = minCount!("a.y > b.y")(vertices)[0];
		auto maxZ = minCount!("a.z > b.z")(vertices)[0];

		auto boundingBox = BoundingBox(vec3(minX.x, minY.y, minZ.z), vec3(maxX.x, maxY.y, maxZ.z));
		obj.m_currentBoundingBox = boundingBox;
		obj.m_navPolygon = loadNavPolygon(Config.Paths.models!string ~ fileName[0.. $ - 3] ~ "nav", boundingBox);

		return obj;
	}

	/**
	 * Loads nav polygon
	 */
	static PolygonDefinition loadNavPolygon(in string navName, in ref BoundingBox boundingBox)
	{
		import std.file : exists;
		import core.stdc.stdio;
		import std.string : toStringz;

		if (!exists(navName))
		{
			// We try to build navpolygon from boundingbox values
			auto polygon = PolygonDefinition(4);
			polygon ~= boundingBox.min; 												// Bottom front-left
			polygon ~= vec3(boundingBox.min.x, boundingBox.min.y, boundingBox.max.z);  // Bottom back-left
			polygon ~= vec3(boundingBox.max.x, boundingBox.min.y, boundingBox.max.z);  // Bottom back-right
			polygon ~= vec3(boundingBox.max.x, boundingBox.min.y, boundingBox.min.z);	// Bottom front-right

			return polygon;
		}

		/**
		* VERTICES_COUNT : INT
		* FACE : INT , INT , INT , INT , ...
		* VERTICES : FLOAT, FLOAT, FLOAT
		* VERTICES : FLOAT, FLOAT, FLOAT
		* ...
		*/
		auto file = fopen(navName.toStringz(), "rb");
		scope(exit) { fclose(file); }

		int verticesCount;
		fread(&verticesCount, int.sizeof, 1, file);

		auto indices = DynamicArray!int(verticesCount / 3);
		indices.length = verticesCount / 3;
		fread(indices.ptr, int.sizeof, verticesCount / 3, file);

		auto vertices = DynamicArray!vec3(indices.length);
		vertices.length = indices.length;
		fread(vertices.ptr, vec3.sizeof, indices.length, file);

		auto polygon = PolygonDefinition(indices.length);

		// We need to defines vertices in good order
		foreach(i, indice; indices)
		{
			polygon ~= vertices[indice - 1];
		}

		return polygon;
	}

	/**
	 * Loads wavefront material.
	 * Params:
	 *		materialName : material file name
	 */
	static Material[string] loadMaterials(in string materialName)
	{
		auto file = File(materialName);
		scope(exit) file.close;

		Material[string] materials;

		string currentMaterialName = "";

		while (!file.eof())
		{
			immutable string lineHeader = file.readln();

			immutable string[] data = lineHeader.split();

			if (lineHeader.startsWith("newmtl"))
			{
				currentMaterialName = data[1];

				materials[currentMaterialName] = Material(MaterialType.Color);
			}
			else if (lineHeader.startsWith("map_Kd"))
			{
				import std.path : baseName;

				// Texture
				string textureName = data[$ - 1];

				materials[currentMaterialName].type = MaterialType.Texture;
				materials[currentMaterialName].texture = AssetLoader.getInstance().load!(Texture)(textureName.baseName(), false);
			}
			else if (lineHeader.startsWith("Kd"))
			{
				// Color
				materials[currentMaterialName].color = Color(cast(ubyte)(data[1].to!float * 255),
															 cast(ubyte)(data[2].to!float * 255),
															 cast(ubyte)(data[3].to!float * 255));
			}
		}

		return materials;
	}

	@nogc @safe
	@property pure nothrow
	{

		public BoundingBox currentBoundingBox() const
		{
			return this.m_currentBoundingBox;
		}

		public void currentBoundingBox(in ref BoundingBox value)
		{
			this.m_currentBoundingBox = value;
		}

		public PolygonDefinition navPolygon()
		{
			return this.m_navPolygon;
		}

		public int trianglesNumber() const
		{
			return this.m_trianglesNumber;
		}
	}
}

