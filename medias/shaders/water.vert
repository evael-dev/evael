#version 330

layout (location = 0) in vec3 in_Vertex;
layout (location = 1) in vec4 in_Color;
layout (location = 2) in vec3 in_Normal;
layout (location = 3) in vec2 in_TexCoord;

out vec2 texCoord;
out vec4 color;
out vec3 fragPos;
out vec3 normal;
out vec4 shadowCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 lightView;
uniform mat4 lightProjection;
uniform mat4 bias;

void main()
{
    gl_Position = projection * view * model * vec4(in_Vertex, 1.0);
	fragPos = vec3(model * vec4(in_Vertex, 1.0));
	normal = transpose(inverse(mat3(model))) * in_Normal;
    texCoord = in_TexCoord;
	color = in_Color;
	
	mat4 lightSpaceMatrix = lightProjection * lightView * model;
	shadowCoord =  bias * lightSpaceMatrix * vec4(fragPos, 1.0);
}