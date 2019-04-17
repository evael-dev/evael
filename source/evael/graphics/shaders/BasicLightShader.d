module evael.graphics.shaders.BasicLightShader;

import evael.graphics.GL;

public import evael.graphics.shaders.Shader;

class BasicLightShader : Shader
{
	public int dirLightDirectionLocation;
	public int dirLightAmbientLocation;
	public int dirLightDiffuseLocation;
	public int dirLightSpecularLocation;
	public int ambientLightValueLocation;
	public int pointsLightsNumberLocation;
	public int pointsLightsLocation;

	public this(Shader shader)
	{
		super(shader);

		this.dirLightDirectionLocation = this.getUniformLocation("dirLight.direction");
		this.dirLightAmbientLocation = this.getUniformLocation("dirLight.ambient");
		this.dirLightDiffuseLocation = this.getUniformLocation("dirLight.diffuse");
		this.dirLightSpecularLocation = this.getUniformLocation("dirLight.specular");
		this.ambientLightValueLocation = this.getUniformLocation("ambientLight.value");
		this.pointsLightsNumberLocation = this.getUniformLocation("pointsLightsNumber");
		this.pointsLightsLocation = this.getUniformLocation("pointsLights[0].position");
	}
}