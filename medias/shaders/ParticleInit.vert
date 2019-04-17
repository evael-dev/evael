#version 330 

in vec3 in_Position; 
in vec3 in_Velocity; 
in vec3 in_Color; 
in float in_LifeTime; 
in float in_Size; 
in int in_Type; 

out vec3 vPositionPass; 
out vec3 vVelocityPass; 
out vec3 vColorPass; 
out float fLifeTimePass; 
out float fSizePass; 
out int iTypePass; 

void main() 
{ 
  vPositionPass = in_Position; 
  vVelocityPass = in_Velocity; 
  vColorPass = in_Color; 
  fLifeTimePass = in_LifeTime;
  fSizePass = in_Size; 
  iTypePass = in_Type; 
}