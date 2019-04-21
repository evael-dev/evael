module evael.graphics.particles.Particle;

import evael.utils.math;

import evael.utils.Color;

struct Particle
{
	vec3 position; 
	vec3 velocity; 
	vec3 color; 
	float lifeTime; 
	float size; 

	/// Particle (1) or generator (0)
	int type; 
}