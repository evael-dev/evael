#version 330

layout (location = 0) in vec3 in_Vertex;
layout (location = 1) in vec4 in_Color;
layout (location = 2) in vec3 in_Normal;
layout (location = 3) in vec2 in_TexCoord;
layout (location = 4) in vec3 in_Tangent;
layout (location = 5) in vec3 in_Bitangent;
layout (location = 6) in float in_TextureId;
layout (location = 7) in float in_BlendingTextureId;

out vec3 fragPos;
out vec4 color;
out vec3 normal;
out vec2 texCoord;
out float textureId; 
out float blendingTextureId; 
out vec3 tangentFragPos;
out mat3 TBN;
	
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
	color = in_Color;
	texCoord = in_TexCoord;
	  
	mat3 normalMatrix = transpose(inverse(mat3(model)));
	
	normal = normalMatrix * in_Normal;

	vec3 T = normalize(normalMatrix * in_Tangent);
	vec3 B = normalize(normalMatrix * in_Bitangent);
	vec3 N = normalize(normalMatrix * in_Normal);
		
	TBN = transpose(mat3(T, B, N));  
    tangentFragPos = TBN * fragPos;
	
	mat4 lightSpaceMatrix = lightProjection * lightView * model;
	shadowCoord =  bias * lightSpaceMatrix * vec4(fragPos, 1.0);

	textureId = in_TextureId;
	blendingTextureId = in_BlendingTextureId;
}