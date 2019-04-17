#version 330

uniform sampler2D gColorMap;

smooth in vec2 TexCoord;
flat in vec4 in_Color;

out vec4 FragColor;

void main()
{
    vec4 textureColor = texture2D(gColorMap, TexCoord);
 
    FragColor = textureColor;
}