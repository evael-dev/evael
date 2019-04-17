#version 330

struct AmbientLight
{
	vec3 value;
};

struct DirectionalLight 
{
	vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct PointLight 
{
    vec3 position;  
    vec3 color;

	float ambient;
    float constant;
    float linear;
    float quadratic;
	
	bool isEnabled;
}; 

in vec2 texCoord;
in vec4 color;
in vec3 normal;
in vec3 fragPos; 

out vec4 outputColor;

uniform DirectionalLight dirLight;
uniform PointLight pointsLights[50];
uniform AmbientLight ambientLight;

uniform int pointsLightsNumber;

uniform float factor = 1.0f;
uniform sampler2D myTexture;

vec3 getDirectionalLightColor(const DirectionalLight light, vec3 normal, vec3 viewDir);  
vec3 getPointLightColor(const PointLight light, vec3 normal, vec3 fragPos);

void main()
{
	vec3 n = normalize(normal);
    vec3 viewDir = normalize(fragPos);

    vec3 result = getDirectionalLightColor(dirLight, n, viewDir);
	
	for(int i = 0; i < pointsLightsNumber; i++)
	{
		if(pointsLights[i].isEnabled)
		{
			result += getPointLightColor(pointsLights[i], n, fragPos);
		}
	}
	
	result += ambientLight.value;

	outputColor = vec4(result * color.rgb * factor, 1.0);
}

vec3 getDirectionalLightColor(const DirectionalLight light, vec3 normal, vec3 viewDir)
{
    vec3 lightDir = normalize(-light.direction);
    // Diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // Specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);
    // Combine results
    vec3 ambient  = light.ambient;
    vec3 diffuse  = light.diffuse  * diff;
    vec3 specular = light.specular * spec;

	return (ambient + diffuse + specular);
}  

vec3 getPointLightColor(const PointLight light, vec3 normal, vec3 fragPos) 
{
	vec3 vPosToLight = fragPos - light.position; 
	float fDist = length(vPosToLight); 
	vPosToLight = normalize(vPosToLight); 

	float fDiffuse = max(0.0, dot(normal, -vPosToLight)); 
	float fAttTotal = light.constant + light.linear * fDist + light.quadratic * fDist * fDist; 

	return light.color * (light.ambient + fDiffuse) / fAttTotal; 
}