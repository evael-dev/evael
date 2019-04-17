#version 330 

layout (location = 0) in vec3 in_Vertex;
layout (location = 4) in vec4 in_Bones;
layout (location = 5) in vec4 in_Weights;

uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;

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
}  