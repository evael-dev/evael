#version 330

layout(points) in;
layout(triangle_strip) out;
layout(max_vertices = 4) out;

in vec4 in_Color[];

smooth out vec2 TexCoord;
flat out vec4 vColor;          

uniform float bbSize;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()                                     
{
	vColor = in_Color[0];
	
	vec4 center = view * model * gl_in[0].gl_Position;
		
    gl_Position = projection * (center + vec4(-bbSize, -bbSize, 0, 0));
    TexCoord = vec2(0.0, 0.0);
    EmitVertex();


    gl_Position = projection * (center + vec4(-bbSize, bbSize, 0, 0));
    TexCoord = vec2(0.0, 1.0);
    EmitVertex();


    gl_Position = projection * (center + vec4(bbSize, -bbSize, 0, 0));
    TexCoord = vec2(1.0, 0.0);
    EmitVertex();


    gl_Position = projection * (center + vec4(bbSize, bbSize, 0, 0));
    TexCoord = vec2(1.0, 1.0);
    EmitVertex();

    EndPrimitive();
}                                               