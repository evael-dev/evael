module evael.graphics.lights.PointLight;

import evael.graphics.lights.Light;

import evael.utils.Math;

class PointLight : Light
{
	public vec3 position;  
	public vec3 color;

	public float ambient;
	public float constant;
	public float linear;
	public float quadratic;

	public bool isEnabled;
	
	public this(in vec3 position, in vec3 color, in float ambient, in float constant, in float linear, in float quadratic, in bool isEnabled = true)
	{
		this.position = position;
		this.color = color;

		this.ambient = ambient;
		this.constant = constant;
		this.linear = linear;
		this.quadratic = quadratic;

		this.isEnabled = isEnabled;
	}
}