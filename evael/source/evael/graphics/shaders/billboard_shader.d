module evael.graphics.shaders.billboard_shader;

import evael.graphics.gl;

public import evael.graphics.shaders.shader;

class BillboardShader : Shader
{
	public int billboardSize;

	public this(Shader shader)
	{
		super(shader);

		this.billboardSize = this.getUniformLocation("bbSize");
	}
}