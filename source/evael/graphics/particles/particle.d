module evael.graphics.particles.particle;

import evael.utils.math;
import evael.utils.color;

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