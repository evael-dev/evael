module evael.graphics.lights.DirectionalLight;

import evael.graphics.lights.Light;

import evael.utils.Math;

class DirectionalLight : Light
{
	public vec3 direction;
	public vec3 ambient;
	public vec3 diffuse;
	public vec3 specular;
	
	@nogc @safe
	public this() pure nothrow
	{

	}
	
	@nogc @safe
	public this(in vec3 direction, in vec3 ambient, in vec3 diffuse, in vec3 specular) pure nothrow
	{
		this.direction = direction;
		this.ambient = ambient;
		this.diffuse = diffuse;
		this.specular = specular;
	}
}