#version 330

layout (location = 0) in vec3 in_Vertex;
layout (location = 1) in vec4 in_Color;
layout (location = 2) in vec3 in_Normal;
layout (location = 3) in vec2 in_TexCoord;
layout (location = 4) in mat4 in_Model;
layout (location = 8) in float in_ColorMul;
layout (location = 9) in float in_Textured;
layout (location = 10) in float in_Displayed;

out vec4 color;
out vec2 texCoord;
out vec3 normal;
out vec3 fragPos;
out float colorMul;
out float textured;
out float displayed;

uniform mat4 view;
uniform mat4 projection;

void main()
{
	// This matrix is sent trough vertex attributes, we cant transpose on param like glUniformxxx
	mat4 transposedModelMatrix = transpose(in_Model);
	
    gl_Position = projection * view * transposedModelMatrix * vec4(in_Vertex, 1.0);
	fragPos = vec3(transposedModelMatrix * vec4(in_Vertex, 1.0));
    color = in_Color;
    texCoord = in_TexCoord;
	normal = in_Normal;
	colorMul = in_ColorMul;
	textured = in_Textured;
	displayed = in_Displayed;
}