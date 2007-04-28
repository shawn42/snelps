/**
 * Vector functions
 */
#include "ruby3d.h"

/**
 * Add two vectors
 */
void r3d_vector_add(Vector* result, Vector* self, Vector* other)
{
	result->x = self->x + other->x;
	result->y = self->y + other->y;
	result->z = self->z + other->z;
}

void r3d_vector_subtract(Vector* result, Vector* self, Vector* other)
{
	result->x = self->x - other->x;
	result->y = self->y - other->y;
	result->z = self->z - other->z;
}

void r3d_vector_multiply(Vector* result, Vector* self, float mult)
{	
	result->x = self->x * mult;
	result->y = self->y * mult;
	result->z = self->z * mult;
}

void r3d_vector_divide(Vector* result, Vector* self, float mult)
{	
	result->x = self->x / mult;
	result->y = self->y / mult;
	result->z = self->z / mult;
}

void r3d_vector_negate(Vector* result, Vector* self)
{
	result->x = -self->x;
	result->y = -self->y;
	result->z = -self->z;
}

void r3d_vector_dot(float* result, Vector* self, Vector* other)
{	
	*result = self->x * other->x + self->y * other->y + self->z * other->z;
}

void r3d_vector_cross(Vector* result, Vector* self, Vector* other)
{	
	result->x = self->y * other->z - self->z * other->y;
	result->y = self->z * other->x - self->x * other->z;
	result->z = self->x * other->y - self->y * other->x;
}

void r3d_vector_length(float* result, Vector* self)
{
	*result = sqrt(self->x * self->x + self->y * self->y + self->z * self->z);
}

void r3d_vector_squared_length(float* result, Vector* self)
{
	*result = self->x * self->x + self->y * self->y + self->z * self->z;
}

void r3d_vector_normalize(Vector* result, Vector* self)
{
	float length;
	r3d_vector_length(&length, self);

	result->x = self->x / length;
	result->y = self->y / length;
	result->z = self->z / length;
}

void r3d_vector_rotate_to(Rotation* result, Vector* self, Vector* dest)
{
	// Based on Stan Melax's article in Game Programming Gems
	Vector* v0 = self;
	Vector* v1 = dest;
	Vector c;
	float d;

	r3d_vector_normalize(v0, v0);
	r3d_vector_normalize(v1, v1);

	r3d_vector_cross(&c, v0, v1);

	// Note that if the cross product approaches zero, we get unstable because ANY
	// axis will do when v0 == -v1
	
	r3d_vector_dot(&d, v0, v1);
	
	if (d >= 1.0f)
	{
		result->x = 0.0f;
		result->y = 0.0f;
		result->z = 0.0f;
		result->w = 1.0f;
	}
	else
	{
		float invs;
		float s = sqrt( (1 + d) * 2 );	

		if (s == 0)
		{
			// If this happens == VERY BAD
			return;
		}

		invs = 1.0 / s;

		result->x = c.x * invs;
		result->y = c.y * invs;
		result->z = c.z * invs;
		result->w = s * 0.5;
	}
}
