module evael.graphics.shaders.IqmShader;

import evael.graphics.GL;

public import evael.graphics.shaders.Shader;
import evael.graphics.shaders.BasicModelShader;

class IqmShader : BasicModelShader
{
	public int boneMatrices;

	public this(Shader shader)
	{
		super(shader);

		this.boneMatrices = this.getUniformLocation("bonemats[0]");
	}
}