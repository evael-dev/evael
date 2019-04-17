#version 330

layout(points) in;
layout(triangle_strip) out;
layout(max_vertices = 4) out;

in vec3 vColorPass[]; 
in float fLifeTimePass[]; 
in float fSizePass[]; 
in int iTypePass[];

smooth out vec2 TexCoord;
flat out vec4 vColor;          

uniform mat4 modelView;
uniform mat4 projection;

void main()                                     
{
  if(iTypePass[0] != 0)
  {
		vColor = vec4(vColorPass[0], fLifeTimePass[0]);
		
		vec4 center = modelView * gl_in[0].gl_Position;
			
		gl_Position = projection * (center + vec4(-fSizePass[0], -fSizePass[0], 0, 0));
		TexCoord = vec2(0.0, 0.0);
		EmitVertex();


		gl_Position = projection * (center + vec4(-fSizePass[0], fSizePass[0], 0, 0));
		TexCoord = vec2(0.0, 1.0);
		EmitVertex();


		gl_Position = projection * (center + vec4(fSizePass[0], -fSizePass[0], 0, 0));
		TexCoord = vec2(1.0, 0.0);
		EmitVertex();


		gl_Position = projection * (center + vec4(fSizePass[0], fSizePass[0], 0, 0));
		TexCoord = vec2(1.0, 1.0);
		EmitVertex();

		EndPrimitive();
	}
}                                               