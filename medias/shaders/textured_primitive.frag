#version 330

in vec2 texCoord;
in vec4 color;

// pour mettre en surbrillance
uniform float factor = 1.0f;

out vec4 FragColor;
uniform sampler2D tex;

void main()
{
    FragColor = texture(tex, texCoord) * color * factor;
}