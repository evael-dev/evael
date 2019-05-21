module evael.graphics.Terrain;

import std.exception : enforce;
import std.random : uniform;
import std.math;

import evael.graphics.GraphicsDevice;
import evael.graphics.Drawable;
import evael.graphics.shaders.BasicTerrainShader;
import evael.graphics.Vertex;
import evael.graphics.Texture;
import evael.graphics.TextureArray;
import evael.graphics.lights;

import evael.utils.Math;
import evael.utils.Color;
import evael.utils.Size;

/**
 * Terrain
 */
class Terrain : Drawable
{
    struct TerrainHeader
    {
        public Size!int size;
        public int      textureSplatting;
        public int      XZworldScaleFactor;
        public float    YworldScaleFactor;
    }

    /// Terrain configuration
    private TerrainHeader m_header;

    private Texture m_blendMapTexture;
    private Texture m_shadowMapTexture;
    private Texture m_normalMap;

    /// Terrain textures
    private TextureArray m_textures;

    private uint m_trianglesNumber;

    /**
     * Terrain constructor.
     * Params:
     *      graphicsDevice  :
     *      header : terrain configuration
     *      textures : textures
     */
    @nogc
    public this()(GraphicsDevice graphicsDevice, in auto ref TerrainHeader header, TextureArray textures) nothrow
    {
        super(graphicsDevice);
        this.m_header = header;
        this.m_textures = textures;
    }

    /**
     * Terrain destructor.
     */
    @nogc
    public void dispose() nothrow
    {
        this.m_textures.dispose();
    }

    /**
     * Initializes terrain.
     */
    public void initialize()
    {
        TerrainVertex[] vertices = null;

        immutable int halfWidth = (this.m_header.size.width / 2), halfHeight = (this.m_header.size.height / 2);

        for (int z = -halfHeight; z < halfHeight; z++)
        {
            for (int x = -halfWidth; x < halfWidth; x++)
            {
                vertices ~= TerrainVertex(
                    vec3(x * this.m_header.XZworldScaleFactor, this.m_header.YworldScaleFactor, z * this.m_header.XZworldScaleFactor),
                    Color.White,
                    vec3(0, 0, 0),
                    vec2(cast(float)x / this.m_header.textureSplatting, cast(float)z / this.m_header.textureSplatting),
                    vec3(0, 0, 0),
                    vec3(0, 0, 0),
                    0,
                    0
                );
            }
        }

        uint[] indices = null;

        // Generating indices
        for (int y = 0; y < this.m_header.size.height - 1 ; y++)
        {
            for (int x = 0; x < this.m_header.size.width - 1 ; x++)
            {
                immutable uint vertexIndex = (y * this.m_header.size.width) + x;

                // Top triangle (T0)
                immutable uint indice1 = vertexIndex;
                immutable uint indice2 = vertexIndex + this.m_header.size.width + 1;
                immutable uint indice3 = vertexIndex + 1;

                // Bottom triangle (T1)
                immutable uint indice4 = vertexIndex;
                immutable uint indice5 = vertexIndex + this.m_header.size.width;
                immutable uint indice6 = vertexIndex + this.m_header.size.width + 1;

                indices ~= [indice1, indice2, indice3, indice4, indice5, indice6];
            }
        }

        // We compute normals
        for (int i = 0; i < indices.length; i += 3)
        {
            vec3 p0 = vertices[indices[i+0]].position;
            vec3 p1 = vertices[indices[i+1]].position;
            vec3 p2 = vertices[indices[i+2]].position;

            vec3 e1 = p1 - p0;
            vec3 e2 = p2 - p0;
            vec3 normal = cross(e1, e2);
            normal.normalize();

            vertices[indices[i]].normal   = vertices[indices[i]].normal   + normal;
            vertices[indices[i+1]].normal = vertices[indices[i+1]].normal + normal;
            vertices[indices[i+2]].normal = vertices[indices[i+2]].normal + normal;
        }

        foreach (ref vertice; vertices)
        {
            vertice.normal.normalize();
        }

        this.m_vao = this.m_graphicsDevice.generateVAO();
        this.m_vertexBuffer = this.m_graphicsDevice.createVertexBuffer(TerrainVertex.sizeof * vertices.length, vertices.ptr);
        this.m_indexBuffer = this.m_graphicsDevice.createIndexBuffer(uint.sizeof * indices.length, indices.ptr);

        this.m_graphicsDevice.setVertexBuffer!(TerrainVertex)(this.m_vertexBuffer);
        this.m_graphicsDevice.bindVAO(0);

        this.m_trianglesNumber = cast(int) (indices.length / 3);
    }

    public override void draw(in float deltaTime,  mat4 view, mat4 projection)
    {
    }

    public void drawWithShadow(in float deltaTime, mat4 view, mat4 projection, mat4 lightView, mat4 lightProjection)
    {
        mat4 model = mat4.identity;

        this.m_graphicsDevice.enableShader(this.m_shader);

        auto terrainShader = cast(BasicTerrainShader)this.m_shader;
    
        gl.ActiveTexture(GL_TEXTURE3);
        this.m_graphicsDevice.bindTexture(this.m_blendMapTexture);
        gl.Uniform1i(terrainShader.blendMapLocation, 3);

        gl.ActiveTexture(GL_TEXTURE2);
        this.m_graphicsDevice.bindTexture(this.m_textures.id, TextureTarget.TextureArray);
        gl.Uniform1i(terrainShader.terrainTexturesLocation, 2);

        gl.ActiveTexture(GL_TEXTURE1);
        this.m_graphicsDevice.bindTexture(this.m_shadowMapTexture);
        gl.Uniform1i(terrainShader.shadowMapLocation, 1);

        this.m_graphicsDevice.setMatrix(terrainShader.viewMatrix, view.arrayof.ptr);
        this.m_graphicsDevice.setMatrix(terrainShader.modelMatrix, model.arrayof.ptr);
        this.m_graphicsDevice.setMatrix(terrainShader.projectionMatrix, projection.arrayof.ptr);
        this.m_graphicsDevice.setMatrix(terrainShader.lightViewMatrix, lightView.arrayof.ptr);
        this.m_graphicsDevice.setMatrix(terrainShader.lightProjectionMatrix, lightProjection.arrayof.ptr);

        static float[16] bias =
        [
            0.5, 0.0, 0.0, 0.0,
            0.0, 0.5, 0.0, 0.0,
            0.0, 0.0, 0.5, 0.0,
            0.5, 0.5, 0.5, 1.0
        ];

        this.m_graphicsDevice.setMatrix(terrainShader.biasMatrix, bias.ptr, 1, false);

        // Lighting
        this.m_graphicsDevice.setEnvironment();

        this.m_graphicsDevice.bindVAO(this.m_vao);
        this.m_graphicsDevice.drawIndexedPrimitives!(PrimitiveType.Triangle)(this.m_trianglesNumber);
        this.m_graphicsDevice.bindVAO(0);

        this.m_graphicsDevice.disableShader();

        gl.ActiveTexture(GL_TEXTURE0);
    }

    public void loadFromHeightmap(in string heightmap)
    {
        ubyte[] bytes = Texture.loadBytes(heightmap);

        immutable int width = this.m_header.size.width;
		immutable int height = this.m_header.size.height;
        immutable int halfWidth = (this.m_header.size.width / 2);
		immutable int halfHeight = (this.m_header.size.height / 2);

        TerrainVertex[] vertices = null;

        for (int z = -halfHeight; z < halfHeight; z++)
        {
            for (int x = -halfWidth; x < halfWidth; x++)
            {
                // bytes[(z * width + x) * 4];
                immutable int redIndex = ((z + halfHeight) * width + (x + halfWidth)) * 4;

                // Free image is BGR(A)
                immutable int blue = bytes[redIndex];
                immutable int green = bytes[redIndex + 1];
                immutable int red = bytes[redIndex + 2];

                immutable color = Color(blue, green, red);
                float y = 0.0f;
                int textureId = 0;

                auto position = vec3(x * this.m_header.XZworldScaleFactor, y, z * this.m_header.XZworldScaleFactor);

                vertices ~= TerrainVertex(position,
                    Color.White,
                    vec3(0, 0, 0),
                    vec2(cast(float)(x + halfWidth) / width, cast(float)(z + halfHeight) / height),
                    vec3(0, 0, 0),
                    vec3(0, 0, 0),
                    textureId,
                    1.0f);
            }
        }
        
        uint[] indices = null;

        // Generating indices
        for (int y = 0; y < this.m_header.size.height - 1 ; y++)
        {
            for (int x = 0; x < this.m_header.size.width - 1 ; x++)
            {
                immutable uint vertexIndex = (y * this.m_header.size.width) + x;

                // Top triangle (T0)
                // ----
                //  \ |
                //   \|
                immutable uint indice1 = vertexIndex;
                immutable uint indice2 = vertexIndex + this.m_header.size.width + 1;
                immutable uint indice3 = vertexIndex + 1;

                // Bottom triangle (T1)
                // |\
                // | \
                // ---- 
                immutable uint indice4 = vertexIndex;
                immutable uint indice5 = vertexIndex + this.m_header.size.width;
                immutable uint indice6 = vertexIndex + this.m_header.size.width + 1;

                indices ~= [indice1, indice2, indice3, indice4, indice5, indice6];
            }
        }

        // We compute normals
        for (int i = 0; i < indices.length; i += 3)
        {
            vec3 p0 = vertices[indices[i+0]].position;
            vec3 p1 = vertices[indices[i+1]].position;
            vec3 p2 = vertices[indices[i+2]].position;

            vec3 e1 = p1 - p0;
            vec3 e2 = p2 - p0;
            vec3 normal = cross(e1, e2);
            normal.normalize();

            // Store the face's normal for each of the vertices that make up the face
            vertices[indices[i]].normal   = vertices[indices[i]].normal   + normal ;
            vertices[indices[i+1]].normal = vertices[indices[i+1]].normal + normal ;
            vertices[indices[i+2]].normal = vertices[indices[i+2]].normal + normal ;

            // Shortcuts for UVs
            auto uv0 = vertices[indices[i+0]].textureCoordinate;
            auto uv1 = vertices[indices[i+1]].textureCoordinate;
            auto uv2 = vertices[indices[i+2]].textureCoordinate;

            // Edges of the triangle : postion delta
            vec3 deltaPos1 = p1-p0;
            vec3 deltaPos2 = p2-p0;

            // UV delta
            vec2 deltaUV1 = uv1-uv0;
            vec2 deltaUV2 = uv2-uv0;

            immutable float r = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV1.y * deltaUV2.x);
            vec3 tangent;

            tangent.x = r * (deltaPos1.x * deltaUV2.y  - deltaPos2.x * deltaUV1.y);
            tangent.y = r * (deltaPos1.y * deltaUV2.y  - deltaPos2.y * deltaUV1.y);
            tangent.z = r * (deltaPos1.z * deltaUV2.y  - deltaPos2.z * deltaUV1.y);
            tangent.normalize();

            vec3 bitangent;
            bitangent.x = (deltaPos2.x * deltaUV1.x  - deltaPos1.x * deltaUV2.x) *r;
            bitangent.y = (deltaPos2.y * deltaUV1.x  - deltaPos1.y * deltaUV2.x) *r;
            bitangent.z = (deltaPos2.z * deltaUV1.x  - deltaPos1.z * deltaUV2.x) *r;
            bitangent.normalize();

            // Set the same tangent for all three vertices of the triangle
            vertices[indices[i+0]].tangent = tangent;
            vertices[indices[i+1]].tangent = tangent;
            vertices[indices[i+2]].tangent = tangent;

            // Same thing for binormals
            vertices[indices[i+0]].bitangent = bitangent;
            vertices[indices[i+1]].bitangent = bitangent;
            vertices[indices[i+2]].bitangent = bitangent;
        }

        foreach (ref vertice; vertices)
        {
            vertice.normal.normalize();
        }

        this.m_vao = this.m_graphicsDevice.generateVAO();
        this.m_vertexBuffer = this.m_graphicsDevice.createVertexBuffer(TerrainVertex.sizeof * vertices.length, vertices.ptr);
        this.m_indexBuffer = this.m_graphicsDevice.createIndexBuffer(uint.sizeof * indices.length, indices.ptr);

        this.m_graphicsDevice.setVertexBuffer!(TerrainVertex)(this.m_vertexBuffer);

        this.m_graphicsDevice.bindVAO(0);

        this.m_trianglesNumber = cast(int) (indices.length / 3);
    }

	@nogc
    @property nothrow
    {
        public ref const(TerrainHeader) header() const
        {
            return this.m_header;
        }

        public void blendMapTexture(Texture value)
        {
            this.m_blendMapTexture = value;
        }

        public void shadowMapTexture(Texture value)
        {
            this.m_shadowMapTexture = value;
        }

        public void normalMap(Texture value)
        {
            this.m_normalMap = value;
        }
    }
}