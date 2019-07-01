module evael.graphics.lights.AmbientLight;

import evael.graphics.lights.Light;

import evael.utils.Math;

class AmbientLight : Light
{
	public vec3 value;
	
	@nogc @safe
	public this(in vec3 value) pure nothrow
	{
		this.value = value;
	}    
}