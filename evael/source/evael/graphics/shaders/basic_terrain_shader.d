module evael.graphics.shaders.basic_terrain_shader;

import evael.graphics.gl;
import evael.graphics.shaders.basic_light_shader;
public import evael.graphics.shaders.shader;

class BasicTerrainShader : BasicLightShader
{
	public int lightViewMatrix;
	public int lightProjectionMatrix;
	public int biasMatrix;

	public int terrainTexturesLocation;
	public int blendMapLocation;
	public int shadowMapLocation;
	public int normalMapLocation;

	public this(Shader shader)
	{
		super(shader);

		this.lightViewMatrix = this.getUniformLocation("lightView");
		this.lightProjectionMatrix = this.getUniformLocation("lightProjection");
		this.biasMatrix = this.getUniformLocation("bias");

		this.terrainTexturesLocation = this.getUniformLocation("terrainTextures");
		this.blendMapLocation = this.getUniformLocation("blendMap");
		this.shadowMapLocation = this.getUniformLocation("shadowMap");
		this.normalMapLocation = this.getUniformLocation("normalMap");
	}
}