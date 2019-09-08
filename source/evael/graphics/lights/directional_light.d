module evael.graphics.lights.directional_light;

import evael.graphics.lights.light;

import evael.utils.math;

class DirectionalLight : Light
{
	public vec3 direction;
	public vec3 ambient;
	public vec3 diffuse;
	public vec3 specular;
	
	@nogc
	public this() nothrow
	{

	}
	
	@nogc
	public this(in vec3 direction, in vec3 ambient, in vec3 diffuse, in vec3 specular) nothrow
	{
		this.direction = direction;
		this.ambient = ambient;
		this.diffuse = diffuse;
		this.specular = specular;
	}
}