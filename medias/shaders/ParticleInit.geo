#version 330 

layout(points) in; 
layout(points) out; 
layout(max_vertices = 40) out; 

// All that we get from vertex shader
in vec3 vPositionPass[]; 
in vec3 vVelocityPass[]; 
in vec3 vColorPass[]; 
in float fLifeTimePass[]; 
in float fSizePass[]; 
in int iTypePass[]; 

// All that we send further
out vec3 vPosition; 
out vec3 vVelocity; 
out vec3 vColor; 
out float fLifeTime; 
out float fSize; 
out int iType; 

uniform vec3 effectPosition; // Position where new particles are spawned
uniform vec3 effectGravity; // Gravity vector for particles - updates velocity of particles 
uniform vec3 effectVelocityMin; // Velocity of new particle - from min to (min+range)
uniform vec3 effectVelocityRange; 
uniform vec3 effectColor; 
uniform float effectSize;  

uniform float effectLifeMin, effectLifeRange; // Life of new particle - from min to (min+range)
uniform float timePassed; // Time passed since last frame

uniform vec3 randomSeed; // Seed number for our random number function
vec3 localSeed; 

uniform int particlesCount; // How many particles will be generated next time

// This function returns random number from zero to one
float randZeroOne() 
{ 
    uint n = floatBitsToUint(localSeed.y * 214013.0 + localSeed.x * 2531011.0 + localSeed.z * 141251.0); 
    n = n * (n * n * 15731u + 789221u); 
    n = (n >> 9u) | 0x3F800000u; 
  
    float fRes =  2.0 - uintBitsToFloat(n); 
    localSeed = vec3(localSeed.x + 147158.0 * fRes, localSeed.y*fRes  + 415161.0 * fRes, localSeed.z + 324154.0*fRes); 
    return fRes; 
} 

void main() 
{ 
	localSeed = randomSeed; 

	vPosition = vPositionPass[0]; 
	vVelocity = vVelocityPass[0]; 
	
	if(iTypePass[0] != 0)
		vPosition += vVelocity*timePassed; 
	if(iTypePass[0] != 0)
		vVelocity += effectGravity*timePassed; 

	vColor = vColorPass[0]; 
	fLifeTime = fLifeTimePass[0]-timePassed; 
	fSize = fSizePass[0]; 
	iType = iTypePass[0];
	
	if(iType == 0) 
	{
		EmitVertex(); 
		EndPrimitive(); 
     
		for(int i = 0; i < particlesCount; i++) 
		{ 
			vPosition = effectPosition; 
			vVelocity = effectVelocityMin  + vec3(effectVelocityRange.x * randZeroOne(), effectVelocityRange.y*randZeroOne(), effectVelocityRange.z*randZeroOne()); 
			vColor = effectColor; 
			fLifeTime = effectLifeMin + effectLifeRange * randZeroOne(); 
			fSize = effectSize; 
			iType = 1; 
			EmitVertex(); 
			EndPrimitive(); 
		} 
	}
	else if(fLifeTime > 0.0)
	{
		EmitVertex(); 
		EndPrimitive(); 
	}
}