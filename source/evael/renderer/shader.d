module evael.renderer.shader;

import evael.renderer.enums.shader_type;

struct Shader
{
    public uint programId;
    public uint vertexShaderId;
    public uint fragmentShaderId;
}

struct ShaderAttribute
{
	int layoutIndex;
	int type;
	int size;
	bool normalized;
}