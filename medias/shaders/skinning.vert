#version 330

layout (location = 0) in vec3 in_Vertex;
layout (location = 1) in vec4 in_Color;
layout (location = 2) in vec3 in_Normal;
layout (location = 3) in vec2 in_TexCoord;
layout (location = 4) in vec4 in_Bones;
layout (location = 5) in vec4 in_Weights;

out vec4 color;
out vec2 texCoord;
out vec3 normal;
out vec3 fragPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform mat4 bonemats[80];

void main()
{	
	mat4 boneTransform = bonemats[int(in_Bones.x)] * in_Weights.x;
	boneTransform += bonemats[int(in_Bones.y)] * in_Weights.y;
	boneTransform += bonemats[int(in_Bones.z)] * in_Weights.z;
	boneTransform += bonemats[int(in_Bones.w)] * in_Weights.w;
	
	vec4 iv = vec4(in_Vertex, 1);
	vec4 mpos = boneTransform * iv;
	gl_Position = projection * view * model * mpos;

	mat3 madjtrans = mat3(cross(boneTransform[1].xyz, boneTransform[2].xyz), cross(boneTransform[2].xyz, boneTransform[0].xyz), cross(boneTransform[0].xyz, boneTransform[1].xyz));
	normal = mat3(transpose(inverse(model))) * (in_Normal * madjtrans);

	color = in_Color;
    texCoord = in_TexCoord;
	fragPos = vec3(model * mpos);
}