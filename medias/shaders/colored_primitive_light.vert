#version 330

layout (location = 0) in vec3 in_Vertex;
layout (location = 1) in vec4 in_Color;
layout (location = 2) in vec3 in_Normal;

out vec4 color;
out vec3 normal;
out vec3 fragPos;

uniform mat4 view;
uniform mat4 model;
uniform mat4 projection;

void main()
{
    gl_Position = projection * view * model * vec4(in_Vertex, 1.0);
	color = in_Color;
	normal = in_Normal;
    fragPos = vec3(model * vec4(in_Vertex, 1.0));
}