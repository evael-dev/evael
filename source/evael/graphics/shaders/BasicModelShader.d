module evael.graphics.shaders.BasicModelShader;

import evael.graphics.GL;

public import evael.graphics.shaders.Shader;
import evael.graphics.shaders.BasicLightShader;

class BasicModelShader : BasicLightShader
{
	public int factor;

	public this(Shader shader)
	{
		super(shader);

		this.factor = this.getUniformLocation("factor");
	}
}