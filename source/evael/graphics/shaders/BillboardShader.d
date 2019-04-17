module evael.graphics.shaders.BillboardShader;

import evael.graphics.GL;

public import evael.graphics.shaders.Shader;

class BillboardShader : Shader
{
	public int billboardSize;

	public this(Shader shader)
	{
		super(shader);

		this.billboardSize = this.getUniformLocation("bbSize");
	}
}