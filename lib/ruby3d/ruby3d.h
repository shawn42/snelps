/**
 * A 3D Math library for Ruby
 *
 * Why I wrote this? After trying to use Yoshi's math3d, I realized that while
 * useful, it is lacking in functionality, and I was unable to figure out how to
 * add my own functions. So I made this in a hope to present Yoshi's math library
 * in a cleaner fashion and easier to understand
 */

#ifndef __MATH__3D__HEADER__
#define __MATH__3D__HEADER__

#include "ruby.h"
#include <math.h>

#define PI	3.14159265358979323846f 

#define DEGTORAD(x) ( ((x) * PI) / 180.0f )
#define RADTODEG(x) ( ((x) * 180.0f) / PI )

#undef FAR
#undef NEAR

/** Type Definitions */

/**
 * Vectors
 * Vectors can be 2,3, or 4 dimentions. To prevent from needing Vector# all 
 * of the time, and because the most common vector is Vector, Vector is
 * also aliased to just Vector
 */

/** 
 * Vector 
 */
typedef struct 
{
	float x, y, z;	
} Vector;

/**
 * Vector4
 */
typedef struct
{
	float x, y, z, w;
} Vector4;

/** 
 * Matrix4
 */
typedef float Matrix4[16];

// Easy accessor macro
#define ELM(mat, row, col) \
    (mat)[(int)(row)*4+(int)(col)]

/**
 * Rotation
 * defined as a Quaternion
 */
typedef struct
{
	float x, y, z, w;
} Rotation;

/**
 * Ray
 */
typedef struct
{
	Vector origin;
	Vector direction;
	float length;
} Ray;

//#define SEG_END_POS(__result__, __seg__) \
//    m3d_vec_scale(__result__, __seg__->len, &__seg__->dir, 3); \
//    m3d_vec_add(__result__, __result__, &__seg__->org, 3)

/**
 * Bounding box
 */
typedef struct
{
	Vector min;
	Vector max;
} Bound;

#define IN_NONE     0
#define IN_MAYBE    1
#define IN_ALL      2

#define MAX(_A, _B) (_A) > (_B) ? (_A) : (_B)
#define MIN(_A, _B) (_A) < (_B) ? (_A) : (_B)

#define BOUND_EMPTY(__bound__) \
    (__bound__->min.x > __bound__->min.x ||  __bound__->min.y > __bound__->max.y || __bound__->min.z > __bound__->max.z) ? 1 : 0

// Hmm, how to do this with x,y,z
//#define BOUND_SIZE(__bound__, __xyz__)  (__bound__->max[__xyz__]-__bound__->min[__xyz__])

/**
 * Plane
 */
typedef Vector4 Plane;

#define PLANE_BACK  0
#define PLANE_ON    1
#define PLANE_FRONT 2

//#define PLANE_DISTANCE(__plane__, __pnt__) (m3d_vec_dot(__plane__, __pnt__, 3) - (*__plane__)[3])

/**
 * Frustum
 */
enum corner_type {
    NEAR_LL,
    NEAR_LR,
    NEAR_HL,
    NEAR_HR,
    FAR_LL,
    FAR_LR,
    FAR_HL,
    FAR_HR,
    CORNER_NUM // Number of corners available
};

enum plane_type
{
	LEFT,
	RIGHT,
	BOTTOM,
	TOP,
	FAR,
	NEAR,
	PLANE_NUM // Number of Planes available
};

typedef struct {
    float near_plane;
		float far_plane;
    Plane plane[PLANE_NUM];
    Vector corner[CORNER_NUM];
} Frustum;

extern Matrix4 mat_identity;
extern Matrix4 mat_zero;

extern Vector vec_zero;
extern Vector vec_unitx;
extern Vector vec_unity;
extern Vector vec_unitz;
extern Vector vec_unit_scale;

extern Rotation rot_identity;

extern Ray ray_default;
extern Plane plane_default;
extern Bound bound_default;
extern Frustum frust_default;

/** 
 * Function prototypes
 */

/** Vector */
void r3d_vector_add(Vector* result, Vector* self, Vector* other);
void m3d_vector_subtract(Vector* result, Vector* self, Vector* other);
void r3d_vector_multiply(Vector* result, Vector* self, float mult);
void r3d_vector_divide(Vector* result, Vector* self, float mult);
void r3d_vector_dot(float* result, Vector* self, Vector* other);
void r3d_vector_cross(Vector* result, Vector* self, Vector* other);
void r3d_vector_length(float* result, Vector* self);
void r3d_vector_squared_length(float* result, Vector* self);
void r3d_vector_normalize(Vector* result, Vector* self);
void r3d_vector_rotate_to(Rotation* result, Vector* self, Vector* dest);
void r3d_vector_negate(Vector* result, Vector* self);

/** Matrix4 */
void r3d_matrix4_add(Matrix4* result, Matrix4* self, Matrix4* other);
void r3d_matrix4_subtract(Matrix4* result, Matrix4* self, Matrix4* other);
void r3d_matrix4_multiply(Matrix4* result, Matrix4* self, Matrix4* other);
void r3d_matrix4_transpose(Matrix4* result, Matrix4* self);
void r3d_matrix4_multiply_vector(Vector* result, Matrix4* self, Vector* other);
void r3d_matrix4_negate(Matrix4* result, Matrix4* self);

/** Rotation */
void r3d_rotation_normalize(Rotation* result);
void r3d_rotation_from_axis_angle(Rotation* result, Vector* axis, float angle);
void r3d_rotation_from_axes(Rotation* result, Vector* xAxis, Vector* yAxis, Vector* zAxis);
void r3d_rotation_from_matrix4(Rotation* result, Matrix4* matrix);
void r3d_rotation_rotate(Rotation* result, float _roll, float _pitch, float _yaw);
void r3d_rotation_to_matrix4(Matrix4* mat, Rotation* rot);
void r3d_rotation_from_matrix4(Rotation* result, Matrix4* mat);
void r3d_rotation_add(Rotation* result, Rotation* self, Rotation* other);
void r3d_rotation_subtract(Rotation* result, Rotation* self, Rotation* other);
void r3d_rotation_multiply_rotation(Rotation* result, Rotation* self, Rotation* other);
void r3d_rotation_multiply_vector(Vector* result, Rotation* self, Vector* other);
void r3d_rotation_multiply_scalar(Rotation* result, Rotation* self, float value);
void r3d_rotation_dot(float* value, Rotation* self, Rotation* other);
void r3d_rotation_norm(float* value, Rotation* self);
void r3d_rotation_inverse(Rotation* result, Rotation* self);
void r3d_rotation_unit_inverse(Rotation* result, Rotation* self);
void r3d_rotation_exp(Rotation* result, Rotation* self);
void r3d_rotation_log(Rotation* result, Rotation* self);
void r3d_rotation_get_roll(float* result, Rotation* self);
void r3d_rotation_get_yaw(float* result, Rotation* self);
void r3d_rotation_get_pitch(float* result, Rotation* self);
#endif
