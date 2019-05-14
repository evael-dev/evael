module evael.graphics.lights.AmbientLight;

import evael.graphics.lights.Light;

import evael.utils.Math;

class AmbientLight : Light
{
	public vec3 value;
	
	public this(in vec3 value)
	{
		this.value = value;
	}    
}