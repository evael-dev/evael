#version 330 

layout (location = 0) in vec3 in_Vertex;
layout (location = 3) in vec2 in_TexCoord;
layout (location = 4) in mat4 in_Model;
layout (location = 10) in float in_Displayed;

out vec2 texCoord;
out float displayed;

uniform mat4 view;
uniform mat4 projection;

void main()
{	
    gl_Position = projection * view * transpose(in_Model) * vec4(in_Vertex, 1);
	
	texCoord = in_TexCoord;
	displayed = in_Displayed;
}  