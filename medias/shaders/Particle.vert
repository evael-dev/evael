#version 330

layout (location = 0) in vec3 vPosition; 
layout (location = 1) in vec3 vColor; 
layout (location = 2) in float fLifeTime; 
layout (location = 3) in float fSize; 
layout (location = 4) in int iType; 

out vec3 vVelocityPass;
out vec3 vColorPass; 
out float fLifeTimePass; 
out float fSizePass; 
out int iTypePass; 

void main()                             
{
	gl_Position = vec4(vPosition, 1.0); 
    vColorPass = vColor; 
    fSizePass = fSize; 
    fLifeTimePass = fLifeTime; 
	iTypePass = iType;
}