#include "ruby3d.h"

// PLEASE NOTE: Most of the algorithms here came from:
//
// Magic Software, Inc.
// http://www.magic-software.com
// Copyright (c) 2000, All Rights Reserved
//
// Source code from Magic Software is supplied under the terms of a license
// agreement and may not be copied or disclosed except in accordance with the
// terms of that agreement.  The various license agreements may be found at
// the Magic Software web site.  This file is subject to the license
//
// FREE SOURCE CODE
// http://www.magic-software.com/License/free.pdf

void r3d_rotation_normalize(Rotation* result)
{
	float len;
	float factor;

	r3d_rotation_norm(&len, result);

	factor = 1.0 / sqrt(len);

	r3d_rotation_multiply_scalar(result, result, factor);
}

// Y axis
void r3d_rotation_get_roll(float* result, Rotation* self)
{
	float value = atan2(2 * (self->x * self->y + self->w * self->z),
			self->w * self->w + self->x * self->x - self->y * self->y - self->z * self->z);

	(*result) = RADTODEG(value);
}

// Z axis
void r3d_rotation_get_yaw(float* result, Rotation* self)
{
	float value = atan2(2 * (self->y * self->z + self->w * self->x),
			self->w * self->w - self->x * self->x - self->y * self->y + self->z * self->z);

	(*result) = RADTODEG(value);
}

// X axis
void r3d_rotation_get_pitch(float* result, Rotation* self)
{
	float value = asin(-2 * (self->x * self->z - self->w * self->y));

	(*result) = RADTODEG(value);
}

void r3d_rotation_from_axis_angle(Rotation* result, Vector* axis, float angle)
{
	float halfAngle = 0.5 * DEGTORAD(angle);
	float fSin = sin(halfAngle);

	result->x = fSin * axis->x;
	result->y = fSin * axis->y;
	result->z = fSin * axis->z;
	result->w = cos(halfAngle);
}

void r3d_rotation_from_axes(Rotation* result, Vector* xAxis, Vector* yAxis, Vector* zAxis)
{
	Matrix4 mat;
	int col;

	ELM(mat,0,0) = xAxis->x;
	ELM(mat,1,0) = xAxis->y;
	ELM(mat,2,0) = xAxis->z;
	ELM(mat,3,0) = 0.0f;

	ELM(mat,0,1) = yAxis->x;
	ELM(mat,1,1) = yAxis->y;
	ELM(mat,2,1) = yAxis->z;
	ELM(mat,3,1) = 0.0f;

	ELM(mat,0,2) = zAxis->x;
	ELM(mat,1,2) = zAxis->y;
	ELM(mat,2,2) = zAxis->z;
	ELM(mat,2,3) = 0.0f;

	ELM(mat,3,3) = 1.0f;

	r3d_rotation_from_matrix4(result, &mat);
}

void r3d_rotation_to_axes(Rotation* self, Vector* xAxis, Vector* yAxis, Vector* zAxis)
{
	Matrix4 mat;

	r3d_rotation_to_matrix4(&mat, self);

	xAxis->x = ELM(mat,0,0);
	xAxis->y = ELM(mat,1,0);
	xAxis->z = ELM(mat,2,0);

	yAxis->x = ELM(mat,0,1);
	yAxis->y = ELM(mat,1,1);
	yAxis->z = ELM(mat,2,1);

	zAxis->x = ELM(mat,0,2);
	zAxis->y = ELM(mat,1,2);
	zAxis->z = ELM(mat,2,2);
}

void r3d_rotation_rotate(Rotation* result, float _roll, float _pitch, float _yaw)
{
	float roll, pitch, yaw, cosX, cosY, cosZ, sinX, sinY, sinZ;

	roll = 0.5f * DEGTORAD(_roll);
	pitch = 0.5f * DEGTORAD(_pitch);
	yaw = 0.5f * DEGTORAD(_yaw);	

	cosX = cos(pitch);
	cosY = cos(roll);
	cosZ = cos(yaw);

	sinX = sin(pitch);
	sinY = sin(roll);
	sinZ = sin(yaw);

	result->w = cosX * cosY * cosZ + sinX * sinY * sinZ;
	result->x = sinX * cosY * cosZ - cosX * sinY * sinZ;
	result->y = cosX * sinY * cosZ + sinX * cosY * sinZ;
	result->z = cosX * cosY * sinZ - sinX * sinY * cosZ;
	r3d_rotation_normalize(result);
}

void r3d_rotation_from_matrix4(Rotation* result, Matrix4* matrix)
{
	// Algorithm in Ken Shoemake's article in 1987 SIGGRAPH course notes
	// article "Quaternion Calculus and Fast Animation".

	float trace = ELM(*matrix,0,0) + ELM(*matrix,1,1) + ELM(*matrix,2,2);
	float root;

	if (trace > 0.0)
	{
		root = sqrt(trace + 1.0);
		result->w = 0.5 * root;
		root = 0.5 / root;

		result->x = (ELM(*matrix,2,1) - ELM(*matrix,1,2)) * root;
		result->y = (ELM(*matrix,0,2) - ELM(*matrix,2,0)) * root;
		result->z = (ELM(*matrix,1,0) - ELM(*matrix,0,1)) * root;
	}
	else
	{
		int next[3] = { 1, 2, 0 };
		float* apkQuat[3] = { &(result->x), &(result->y), &(result->z) };
		int i = 0;
		int j, k;

		if (ELM(*matrix,1,1) > ELM(*matrix,0,0))
		{
			i = 1;
		}

		if (ELM(*matrix,2,2) > ELM(*matrix,i,i))
		{
			i = 2;
		}

		j = next[i];
		k = next[j];

		root = sqrt(ELM(*matrix,i,i) - ELM(*matrix,j,j) - ELM(*matrix,k,k) + 1.0);

		(*apkQuat)[i] = 0.5 * root;
		root = 0.5 / root;
		result->w = (ELM(*matrix,k,j) - ELM(*matrix,j,k)) * root;

		(*apkQuat)[j] = ( ELM(*matrix,j,i) + ELM(*matrix,i,j) ) * root;
		(*apkQuat)[k] = ( ELM(*matrix,k,i) + ELM(*matrix,i,k) ) * root;
	}
}

void r3d_rotation_to_matrix4(Matrix4* result, Rotation* rot)
{
	float fTx  = 2.0 * rot->x;
	float fTy  = 2.0 * rot->y;
	float fTz  = 2.0 * rot->z;
	float fTwx = fTx * rot->w;
	float fTwy = fTy * rot->w;
	float fTwz = fTz * rot->w;
	float fTxx = fTx * rot->x;
	float fTxy = fTy * rot->x;
	float fTxz = fTz * rot->x;
	float fTyy = fTy * rot->y;
	float fTyz = fTz * rot->y;
	float fTzz = fTz * rot->z;

	ELM(*result,0,0) = 1.0-(fTyy+fTzz);
	ELM(*result,0,1) = fTxy-fTwz;
	ELM(*result,0,2) = fTxz+fTwy;
	ELM(*result,0,3) = 0.0f;		

	ELM(*result,1,0) = fTxy+fTwz;
	ELM(*result,1,1) = 1.0-(fTxx+fTzz);
	ELM(*result,1,2) = fTyz-fTwx;
	ELM(*result,1,3) = 0.0f;

	ELM(*result,2,0) = fTxz-fTwy;
	ELM(*result,2,1) = fTyz+fTwx;
	ELM(*result,2,2) = 1.0-(fTxx+fTyy);
	ELM(*result,2,3) = 0.0f;

	ELM(*result,3,0) = 0.0f;
	ELM(*result,3,1) = 0.0f;
	ELM(*result,3,2) = 0.0f;
	ELM(*result,3,3) = 1.0f;
}

void r3d_rotation_add(Rotation* result, Rotation* self, Rotation* other)
{
	result->x = self->x + other->x;
	result->y = self->y + other->y;
	result->z = self->z + other->z;
	result->w = self->w + other->w;
}

void r3d_rotation_subtract(Rotation* result, Rotation* self, Rotation* other)
{
	result->x = self->x - other->x;
	result->y = self->y - other->y;
	result->z = self->z - other->z;
	result->w = self->w - other->w;
}

void r3d_rotation_multiply_rotation(
		Rotation* result, Rotation* self, Rotation* other)
{
	result->w = self->w * other->w - self->x * other->x - self->y * other->y - 
		self->z * other->z;
	result->x = self->w * other->x + self->x * other->w + self->y * other->z - 
		self->z * other->y;
	result->y = self->w * other->y + self->y * other->w + self->z * other->x - 
		self->x * other->z;
	result->z = self->w * other->z + self->z * other->w + self->x * other->y - 
		self->y * other->x;
}

/** Algorithm from nVidia SDK */
void r3d_rotation_multiply_vector(
		Vector* result, Rotation* self, Vector* other)
{
	Vector uv;
	Vector uuv;
	Vector qvec;

	qvec.x = self->x;
	qvec.y = self->y;
	qvec.z = self->z;

	r3d_vector_cross(&uv, &qvec, other);
	r3d_vector_cross(&uuv, &qvec, &uv);
	r3d_vector_multiply(&uv, &uv, (2.0f * self->w));
	r3d_vector_multiply(&uuv, &uuv, 2.0f);

	result->x = other->x + uv.x + uuv.x;
	result->y = other->y + uv.y + uuv.y;
	result->z = other->z + uv.z + uuv.z;
}

void r3d_rotation_multiply_scalar(
		Rotation* result, Rotation* self, float value)
{
	result->x = self->x * value;
	result->y = self->y * value;
	result->z = self->z * value;
	result->w = self->w * value;
}

void r3d_rotation_dot(float* value, Rotation* self, Rotation* other)
{
	(*value) = self->w * other->w + 
		self->x * other->x +
		self->y * other->y +
		self->z * other->z;
}

void r3d_rotation_norm(float* value, Rotation* self)
{
	(*value) = self->w * self->w +
		self->x * self->x + 
		self->y * self->y + 
		self->z * self->z;
}

void r3d_rotation_inverse(Rotation* result, Rotation* self)
{
	float norm;
	float invNorm;

	r3d_rotation_norm(&norm, self);

	if (norm > 0.0)
	{
		invNorm = 1.0 / norm;

		result->x = self->x * invNorm;
		result->y = self->y * invNorm;
		result->z = self->z * invNorm;
		result->w = self->w * invNorm;
	}
	else
	{
		// Can't inverse a 0 quaternion
		result->x = result->y = result->z = result->w = 0.0f;
	}
}

void r3d_rotation_unit_inverse(Rotation* result, Rotation* self)
{
	result->x = -self->x;	
	result->y = -self->y;	
	result->z = -self->z;	
	result->w = self->w;	
}

void r3d_rotation_exp(Rotation* result, Rotation* self)
{
	// If q = A*(x*i+y*j+z*k) where (x,y,z) is unit length, then
	// exp(q) = cos(A)+sin(A)*(x*i+y*j+z*k).  If sin(A) is near zero,
	// use exp(q) = cos(A)+A*(x*i+y*j+z*k) since A/sin(A) has limit 1.

	float fAngle;
	float fSin;
	float coeff;

	fAngle = sqrt(self->x * self->x + self->y * self->y + self->z * self->z);
	fSin = sin(fAngle);

	result->w = cos(fAngle);

	if (fabs(fSin) >= 1e-03)
	{
		coeff = fSin / fAngle;
		result ->x = coeff * self->x;	
		result ->y = coeff * self->y;	
		result ->z = coeff * self->z;	
	}
	else
	{
		result->x = self->x;
		result->y = self->y;
		result->z = self->z;
	}
}

void r3d_rotation_log(Rotation* result, Rotation* self)
{
	// If q = cos(A)+sin(A)*(x*i+y*j+z*k) where (x,y,z) is unit length, then
	// log(q) = A*(x*i+y*j+z*k).  If sin(A) is near zero, use log(q) =
	// sin(A)*(x*i+y*j+z*k) since sin(A)/A has limit 1.
	float fSin;
	float coeff;
	float angle;

	result->w = 0.0;

	if (fabs(self->w) < 1.0)
	{
		angle = acos(self->w);	
		fSin = sin(angle);

		if (fabs(fSin) >= 1e-03)
		{
			coeff = angle / fSin;
			result ->x = coeff * self->x;	
			result ->y = coeff * self->y;	
			result ->z = coeff * self->z;	
		}
	}
	else
	{
		result->x = self->x;
		result->y = self->y;
		result->z = self->z;
	}
}
