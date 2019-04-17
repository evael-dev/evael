#version 330

in vec2 texCoord;
in float displayed;

uniform sampler2D myTexture;

void main()
{
	if (texture(myTexture, texCoord).a < 0.5 || displayed != 1.0f)
	   discard;
	   
     gl_FragDepth = 0;
}