#version 330

in vec4 color;
out vec4 outputColor;

uniform float factor = 1.0f;

void main()
{	
	outputColor = vec4(color.rgb * factor, 1.0);
}