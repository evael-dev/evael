module evael.graphics.shaders.iqm_shader;

import evael.graphics.gl;

public import evael.graphics.shaders.shader;
import evael.graphics.shaders.basic_model_shader;

class IqmShader : BasicModelShader
{
	public int boneMatrices;

	public this(Shader shader)
	{
		super(shader);

		this.boneMatrices = this.getUniformLocation("bonemats[0]");
	}
}