module evael.graphics.lights.ambient_light;

import evael.graphics.lights.light;

import evael.utils.math;

class AmbientLight : Light
{
	public vec3 value;
	
	@nogc
	public this(in vec3 value) nothrow
	{
		this.value = value;
	}    
}