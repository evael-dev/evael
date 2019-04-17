module evael.utils.math.Functions;

import std.math;

import dnogc.DynamicArray;

import evael.utils.Math;

enum degToRad = (PI * 2) / 360;
enum pi = 180 / PI;

alias PolygonDefinition = DynamicArray!vec3;

/**
 * Returns angle between two points.
 */
@nogc
float getAngle(in float deltaX, in float deltaY) nothrow
{
	return atan2(deltaX, deltaY) * pi;
}

/**
 * Returns angle between two points.
 */
@nogc
float getAngle()(in auto ref vec3 a, in auto ref vec3 b) nothrow
{
	return getAngle(b.x - a.x, b.z - a.z);
}

/**
 * Returns distance between two points.
 */
@nogc
int getDistance()(in auto ref vec2 a, in auto ref vec2 b) nothrow
{
	return cast(int)ceil(sqrt(cast(float)(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))));
}

/**
 * Returns distance between two points.
 */
@nogc
int getDistance()(in auto ref vec3 a, in auto ref vec3 b) nothrow
{
	return cast(int)ceil(sqrt(cast(float)(pow(a.x - b.x, 2) + pow(a.z - b.z, 2))));
}

@nogc
bool isPointInTriangle()(in auto ref vec3 p, in auto ref vec3 p0, in auto ref vec3 p1, in auto ref vec3 p2)	 nothrow 
{
	auto s = p0.z * p2.x - p0.x * p2.z + (p2.z - p0.z) * p.x + (p0.x - p2.x) * p.z;
	auto t = p0.x * p1.z - p0.z * p1.x + (p0.z - p1.z) * p.x + (p1.x - p0.x) * p.z;

	if ((s < 0) != (t < 0))
		return false;

	auto A = -p1.z * p2.x + p0.z * (p2.x - p1.x) + p0.x * (p1.z - p2.z) + p1.x * p2.z;
	if (A < 0.0)
	{
		s = -s;
		t = -t;
		A = -A;
	}
	return s > 0 && t > 0 && (s + t) < A;
}

@nogc
bool isPointInTriangle2()(in auto ref vec3 p, in auto ref vec3 p0, in auto ref vec3 p1, in auto ref vec3 p2) nothrow
{
	if ((p.x == p0.x && p.z == p0.z) || (p.x == p1.x && p.z == p1.z) || (p.x == p2.x && p.z == p2.z))
		return true;

	return isPointInTriangle(p, p0, p1, p2);
}

/**
 * Checks if a point is inside a polygon
 * Note : im using z axis instead of y axis
 */
@nogc
bool isPointInPolygon()(in auto ref vec3 p, in auto ref PolygonDefinition polygon) nothrow
{
	// http://stackoverflow.com/questions/217578/how-can-i-determine-whether-a-2d-point-is-within-a-polygon
    // http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
    bool inside = false;
    for(int i = 0, j = polygon.length - 1 ; i < polygon.length; j = i++)
    {
        if ( ( polygon[ i ].z > p.z ) != ( polygon[ j ].z > p.z ) &&
             p.x < ( polygon[ j ].x - polygon[ i ].x ) * ( p.z - polygon[ i ].z ) / ( polygon[ j ].z - polygon[ i ].z ) + polygon[ i ].x )
        {
            inside = !inside;
        }
    }

    return inside;
}


/**
 * Checks if two segments interesect
 */
bool intersect()(in auto ref vec3 p1, in auto ref vec3 p2, in auto ref vec3 p3, in auto ref vec3 p4, out vec3 intersection) nothrow @nogc
{
	// Get the segments' parameters.
	immutable float dx12 = p2.x - p1.x;
	immutable float dy12 = p2.z - p1.z;
	immutable float dx34 = p4.x - p3.x;
	immutable float dy34 = p4.z - p3.z;

	// Solve for t1 and t2
	immutable float denominator = (dy12 * dx34 - dx12 * dy34);
	immutable float t1 = ((p1.x - p3.x) * dy34 + (p3.z - p1.z) * dx34) / denominator;
	immutable float t2 = ((p3.x - p1.x) * dy12 + (p1.z - p3.z) * dx12) / -denominator;

	// Find the point of intersection.
	intersection = vec3(p1.x + dx12 * t1, 0, p1.z + dy12 * t1);

	// The segments intersect if t1 and t2 are between 0 and 1.
	return ((t1 >= 0) && (t1 <= 1) && (t2 >= 0) && (t2 <= 1));
}

/**
 * Checks if a ray intersect with polygon
 */
bool intersectPolygon()(in auto ref vec3 p1, in auto ref vec3 p2, ref PolygonDefinition polygonVertices, out vec3 intersection) nothrow @nogc
{
	for(int i = 0; i < polygonVertices.length; i++)
	{
		int j = ( i + 1 ) % polygonVertices.length;

		if((polygonVertices[i] == p2 || polygonVertices[j] == p2) || (polygonVertices[i] == p1 || polygonVertices[j] == p1))
			continue;

		if(intersect(p1, p2, polygonVertices[i], polygonVertices[j], intersection))
		{
			return true;
		}
	}

	return false;
}