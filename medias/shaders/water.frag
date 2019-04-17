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
in vec3 fragPos; 
in vec3 normal;
in vec4 shadowCoord;

out vec4 outputColor;

uniform DirectionalLight dirLight;
uniform PointLight pointsLights[50];
uniform AmbientLight ambientLight;

uniform int pointsLightsNumber;

uniform sampler2D waterTexture;
uniform sampler2DShadow shadowMap;

vec2 poissonDisk[16] = vec2[]( 
   vec2( -0.94201624, -0.39906216 ), 
   vec2( 0.94558609, -0.76890725 ), 
   vec2( -0.094184101, -0.92938870 ), 
   vec2( 0.34495938, 0.29387760 ), 
   vec2( -0.91588581, 0.45771432 ), 
   vec2( -0.81544232, -0.87912464 ), 
   vec2( -0.38277543, 0.27676845 ), 
   vec2( 0.97484398, 0.75648379 ), 
   vec2( 0.44323325, -0.97511554 ), 
   vec2( 0.53742981, -0.47373420 ), 
   vec2( -0.26496911, -0.41893023 ), 
   vec2( 0.79197514, 0.19090188 ), 
   vec2( -0.24188840, 0.99706507 ), 
   vec2( -0.81409955, 0.91437590 ), 
   vec2( 0.19984126, 0.78641367 ), 
   vec2( 0.14383161, -0.14100790 ) 
);

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
	
	
	float bias = 0.005;
	float visibility = 1.0;
	
	for (int i = 0; i < 4; i++)
	{
		int index = i;
		
		visibility -= 0.1 * ( 1.0 - texture( shadowMap, vec3(shadowCoord.xy + poissonDisk[index] / 700.0,  ( shadowCoord.z - bias ) / shadowCoord.w ) ) );
	}
	
	result *= texture(waterTexture, texCoord).rgb;
	
    outputColor = vec4(result * visibility, texture(waterTexture, texCoord).a);
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

	return (ambient * (diffuse + specular));
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
