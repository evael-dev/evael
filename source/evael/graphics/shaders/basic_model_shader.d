module evael.graphics.shaders.basic_model_shader;

import evael.graphics.gl;

public import evael.graphics.shaders.shader;
import evael.graphics.shaders.basic_light_shader;

class BasicModelShader : BasicLightShader
{
	public int factor;

	public this(Shader shader)
	{
		super(shader);

		this.factor = this.getUniformLocation("factor");
	}
}