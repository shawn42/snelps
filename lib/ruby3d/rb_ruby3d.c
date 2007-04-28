#include <stdio.h>
#include "ruby.h"
#include "ruby3d.h"

#define NUM2FLT(value) \
	(float)NUM2DBL(value)

/************************************
 * matrix
 ************************************/
static VALUE cMatrix4;

#define NewMatrix4(class, matrix) \
	Data_Make_Struct(class, Matrix4, 0, rb_matrix_free, matrix)

#define GetMatrix4(object, matrix) \
	Data_Get_Struct(object, Matrix4, matrix)

/************************************
 * rotation
 ************************************/
static VALUE cRotation;
static VALUE rot_ident;

#define NewRotation(class, rotation) \
	Data_Make_Struct(class, Rotation, 0, rb_free_rotation, rotation)

#define GetRotation(object, rotation) \
	Data_Get_Struct(object, Rotation, rotation)

/************************************
 * vector
 ************************************/
static VALUE cVector;

#define NewVector(object, vec_obj) \
	Data_Make_Struct(object, Vector, 0, rb_free_vector, vec_obj);

#define GetVector(object, vec_obj) \
	Data_Get_Struct(object, Vector, vec_obj);

/************************************
 * Ray
 ************************************/
static VALUE cRay;

#define NewRay(object, ray_obj) \
	Data_Make_Struct(object, Ray, 0, rb_free_ray, ray_obj);

#define GetRay(object, ray_obj) \
	Data_Get_Struct(object, Ray, ray_obj);

/************************************
 * Plane
 ************************************/
static VALUE cPlane;

#define NewPlane(object, plane_obj) \
	Data_Make_Struct(object, Plane, 0, rb_free_plane, plane_obj)

#define GetPlane(object, plane_obj) \
	Data_Get_Struct(object, Plane, plane_obj)

/************************************
 * Bound
 ************************************/
static VALUE cBound;

#define NewBound(object, bound_obj) \
	Data_Make_Struct(object, Bound, 0, rb_free_bound, bound_obj);

#define GetBound(object, bound_obj) \
	Data_Get_Struct(object, Bound, bound_obj);

/************************************
 * Frustum
 ************************************/
static VALUE mFrust; // frustum module
static VALUE cFrust; // frustum class

#define NewFrustum(object, frust_obj) \
	Data_Make_Struct(object, Frustum, 0, rb_free_frust, frust_obj);

#define GetFrustum(object, frust_obj) \
	Data_Get_Struct(object, Frustum, frust_obj);

/************************************
 * module/exceptions
 ************************************/
static VALUE mRuby3d;
static VALUE eInvertError;

/************************************
 * vector operations
 ************************************/

/**
 * Free memory of this vector
 */
static void rb_free_vector(Vector* vec)
{
	free(vec);
}

/**
 * Free memory of this rotation
 */
void rb_free_rotation(Rotation* rot)
{
	free(rot);
}

/**
 * Ruby3d::Vector#initialize
 * Create a new vector3. Expected parameters:
 * 	no parameters: makes the zero vector
 * 	3 parameters: values for x, y, z
 */
static VALUE rb_vector_new(int argc, VALUE* argv, VALUE class)
{
	VALUE new_obj = Qnil;
	Vector* vec;

	new_obj = NewVector(class, vec);

	if (argc == 0)
	{
		vec->x = 0.f;
		vec->y = 0.f;
		vec->z = 0.f;

	}
	else if (argc == 3) 
	{
		vec->x = NUM2FLT(argv[0]);
		vec->y = NUM2FLT(argv[1]);
		vec->z = NUM2FLT(argv[2]);
	}
	else
	{
		rb_raise(rb_eArgError, "Wrong number of parameters: %d. Expect 0 or 3", argc);
	}

	return new_obj;
}

/**
 * Ruby3d::Vector#add
 * Adds two vectors together
 */
static VALUE rb_vector_add(VALUE self, VALUE other)
{
	VALUE new_obj;	
	Vector* result;
	Vector* vec_self;
	Vector* vec_other;

	if (!rb_obj_is_kind_of( other, CLASS_OF(self) ))
	{
		rb_raise(rb_eTypeError,"Expected Vector, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	new_obj = NewVector(CLASS_OF(self), result);

	GetVector(self, vec_self);
	GetVector(other, vec_other);

	r3d_vector_add(result, vec_self, vec_other);

	return new_obj;
}

/** 
 * Ruby3d::Vector#subtract
 * Subtracts two vectors
 */
static VALUE rb_vector_subtract(VALUE self, VALUE other)
{
	VALUE new_obj;	
	Vector* result;
	Vector* vec_self;
	Vector* vec_other;

	if (!rb_obj_is_kind_of( other, CLASS_OF(self) ))
	{
		rb_raise(rb_eTypeError,"Expected Vector, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	new_obj = NewVector(CLASS_OF(self), result);

	GetVector(self, vec_self);
	GetVector(other, vec_other);

	r3d_vector_subtract(result, vec_self, vec_other);

	return new_obj;
}

/**
 * Ruby3d::Vector#multiply
 * Multiply a vector with a scalar
 */
static VALUE rb_vector_multiply(VALUE self, VALUE scalar)
{
	VALUE new_obj;
	Vector* result;
	Vector* vec_self;
	float mult;

	if (!rb_obj_is_kind_of(scalar, rb_cNumeric))
	{
		rb_raise(rb_eTypeError, "Expected a Numeric but got %s", 
				rb_class2name(CLASS_OF(scalar)));
	}

	mult = NUM2FLT(scalar);

	new_obj = NewVector(CLASS_OF(self), result);
	GetVector(self, vec_self);

	r3d_vector_multiply(result, vec_self, mult);

	return new_obj;
}

/**
 * Ruby3d::Vector#divide
 * Divide a vector with a scalar
 */
static VALUE rb_vector_divide(VALUE self, VALUE scalar)
{
	VALUE new_obj;
	Vector* result;
	Vector* vec_self;
	float mult;

	if (!rb_obj_is_kind_of(scalar, rb_cNumeric))
	{
		rb_raise(rb_eTypeError, "Expected a Numeric but got %s", 
				rb_class2name(CLASS_OF(scalar)));
	}

	mult = NUM2FLT(scalar);

	new_obj = NewVector(CLASS_OF(self), result);
	GetVector(self, vec_self);

	r3d_vector_divide(result, vec_self, mult);

	return new_obj;
}

/**
 * Ruby3d::Vector#negate
 * Ruby3d::Vector#-
 * Returns a negated version of the vector
 */
static VALUE rb_vector_negate(VALUE self)
{
	Vector* vec;
	Vector* new;
	VALUE new_obj;

	GetVector(self, vec);
	new_obj = NewVector(CLASS_OF(self), new);

	r3d_vector_negate(new, vec);

	return new_obj;
}

/**
 * Ruby3d::Vector#x
 * Access the value of x of this vector
 */
static VALUE rb_vector_x(VALUE self)
{
	Vector* vec;
	GetVector(self, vec);
	return rb_float_new(vec->x);
}

/**
 * Ruby3d::Vector#y
 * Access the value of y of this vector
 */
static VALUE rb_vector_y(VALUE self)
{
	Vector* vec;
	GetVector(self, vec);
	return rb_float_new(vec->y);
}

/**
 * Ruby3d::Vector#z
 * Access the value of z of this vector
 */
static VALUE rb_vector_z(VALUE self)
{
	Vector* vec;
	GetVector(self, vec);
	return rb_float_new(vec->z);
}

/**
 * Ruby3d::Vector#x=
 * Set the value of x of this vector
 */
static VALUE rb_vector_set_x(VALUE self, VALUE new_val)
{
	Vector* vec;
	GetVector(self, vec);
	vec->x = NUM2FLT(new_val);
	return Qnil;
}

/**
 * Ruby3d::Vector#y=
 * Set the value of y of this vector
 */
static VALUE rb_vector_set_y(VALUE self, VALUE new_val)
{
	Vector* vec;
	GetVector(self, vec);
	vec->y = NUM2FLT(new_val);
	return Qnil;
}

/**
 * Ruby3d::Vector#z=
 * Set the value of z of this vector
 */
static VALUE rb_vector_set_z(VALUE self, VALUE new_val)
{
	Vector* vec;
	GetVector(self, vec);
	vec->z = NUM2FLT(new_val);
	return Qnil;
}

/**
 * Ruby3d::Vector#dot
 * Calculate the dot product of 2 vectors
 */
static VALUE rb_vector_dot(VALUE self, VALUE other)
{
	float dot;
	Vector* vec_self;
	Vector* vec_other;

	if (!rb_obj_is_kind_of( other, CLASS_OF(self) ))
	{
		rb_raise(rb_eTypeError,"Expected Vector, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	GetVector(self, vec_self);
	GetVector(other, vec_other);

	r3d_vector_dot(&dot, vec_self, vec_other);

	return rb_float_new(dot);
}

/**
 * Ruby3d::Vector#cross
 * Calculate the cross product of 2 vectors
 */
static VALUE rb_vector_cross(VALUE self, VALUE other)
{
	VALUE new_obj;	
	Vector* result;
	Vector* vec_self;
	Vector* vec_other;

	if (!rb_obj_is_kind_of( other, CLASS_OF(self) ))
	{
		rb_raise(rb_eTypeError,"Expected Vector, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	new_obj = NewVector(CLASS_OF(self), result);

	GetVector(self, vec_self);
	GetVector(other, vec_other);

	r3d_vector_cross(result, vec_self, vec_other);

	return new_obj;
}

/**
 * Ruby3d::Vector#length
 * Calculate the length this vector
 */
static VALUE rb_vector_length(VALUE self)
{
	Vector* vec;
	float length;
	GetVector(self, vec);

	r3d_vector_length(&length, vec);

	return rb_float_new(length);
}

/**
 * Ruby3d::Vector#normalize
 * Return the normalized version of this vector
 */
static VALUE rb_vector_normalize(VALUE self)
{
	Vector* vec;
	Vector* ret;
	VALUE new_obj;

	GetVector(self, vec);
	new_obj = NewVector(CLASS_OF(self), ret);

	r3d_vector_normalize(ret, vec);

	return new_obj;
}

/**
 * Ruby3d::Vector#normalize!
 * Normalize this vector
 */
static VALUE rb_vector_normalize_self(VALUE self)
{
	Vector* vec;

	GetVector(self, vec);

	r3d_vector_normalize(vec, vec);

	return self;
}

/**
 * Ruby3d::Vector#equal?
 * Test equality of two vectors
 */
static VALUE rb_vector_equal(VALUE self, VALUE other)
{
	Vector* vec_self;
	Vector* vec_other;

	if (!rb_obj_is_kind_of( other, CLASS_OF(self) ))
	{
		rb_raise(rb_eTypeError,"Expected Vector, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	GetVector(self, vec_self);
	GetVector(other, vec_other);

	if (vec_self->x == vec_other->x && 
			vec_self->y == vec_other->y && 	
			vec_self->z == vec_other->z)
	{
		return Qtrue;
	}
	else
	{
		return Qfalse;
	}
}

/**
 * Ruby3d::Vector#rotate_to
 * Generate a rotation that heads towards the given vector.
 * Don't call this if you think the two vectors are near inverted, as then any
 * rotation will work
 */
static VALUE rb_vector_rotate_to(VALUE self, VALUE to)
{
	Vector* vec_self;
	Vector* vec_to;
	Rotation* rot;
	VALUE new_obj;

	if (!rb_obj_is_kind_of(to, cVector))
	{
		rb_raise(rb_eTypeError, "Expected Vector, got %s", rb_class2name(CLASS_OF(to)));
	}

	GetVector(self, vec_self);
	GetVector(to, vec_to);

	new_obj = NewRotation(cRotation, rot);

	r3d_vector_rotate_to(rot, vec_self, vec_to);

	return new_obj;
}

/**
 * Ruby3d::Vector#to_s
 * Stringify this vector
 */
static VALUE rb_vector_print(VALUE self)
{
	VALUE str;
	Vector* vec;
	char buf[64];
	int len;

	GetVector(self, vec);

	str = rb_str_new2("Vector: (");
	len = snprintf(buf, 64, "%f, %f, %f", vec->x, vec->y, vec->z);
	str = rb_str_cat(str, buf, len);
	str = rb_str_cat(str, ")", 1);

	return str;
}

/*************************
 * Matrix
 ************************/
void rb_matrix_free(Matrix4* mat)
{
	free(mat);
}

/**
 * Ruby3d::Matrix4#new
 */
static VALUE rb_matrix_new(int argc, VALUE* argv, VALUE class)
{
	VALUE new_obj;
	Matrix4* mat;
	int i;

	new_obj = NewMatrix4(class, mat);

	// Default matrix
	if (argc == 0)
	{
		memcpy(*mat, mat_zero, sizeof(Matrix4));
	}
	else if (argc == 1)
	{
		VALUE arg = argv[0];
		Check_Type(arg, T_ARRAY);
		if (RARRAY(arg)->len == 16)
		{
			for(i = 0; i < 16; i++)
			{
				if (!rb_obj_is_kind_of(RARRAY(arg)->ptr[i], rb_cNumeric))
				{
					rb_raise(rb_eTypeError, "Expected Numeric, but received %s", 
							rb_class2name(CLASS_OF(RARRAY(arg)->ptr[i])));
				}
				else
				{
					(*mat)[i] = NUM2FLT(RARRAY(arg)->ptr[i]);
				}
			}
		}
		else
		{
			rb_raise(rb_eArgError, "Wrong number of elements in Array (%d for 4)",
					RARRAY(arg)->len);
		}
	}
	else
	{
		rb_raise(rb_eArgError, "Wrong number of arguments (%d for 0 or 1)",
				argc);
	}

	return new_obj;
}

/**
 * Ruby3d::Matrix4#add
 * Adds two matricies together
 */
static VALUE rb_matrix_add(VALUE self, VALUE other)
{
	Matrix4* mat_self;
	Matrix4* mat_other;
	Matrix4* mat_new;
	VALUE new_obj;

	if (!rb_obj_is_kind_of( other, cMatrix4 ))
	{
		rb_raise(rb_eTypeError, "No implicit conversion from Matrix4 to %s",
				rb_class2name(CLASS_OF(other)));
	}

	GetMatrix4(self, mat_self);
	GetMatrix4(other, mat_other);

	new_obj = NewMatrix4(CLASS_OF(self), mat_new);

	r3d_matrix4_add(mat_new, mat_self, mat_other);

	return new_obj;
}

/**
 * Ruby3d::Matrix4#subtract
 * subtracts self from other and returns the value
 */
static VALUE rb_matrix_subtract(VALUE self, VALUE other)
{
	Matrix4* mat_self;
	Matrix4* mat_other;
	Matrix4* mat_new;
	VALUE new_obj;

	if (!rb_obj_is_kind_of( other, cMatrix4 ))
	{
		rb_raise(rb_eTypeError, "No implicit conversion from Matrix4 to %s",
				rb_class2name(CLASS_OF(other)));
	}

	GetMatrix4(self, mat_self);
	GetMatrix4(other, mat_other);

	new_obj = NewMatrix4(CLASS_OF(self), mat_new);

	r3d_matrix4_subtract(mat_new, mat_self, mat_other);

	return new_obj;
}

/**
 * Ruby3d::Matrix4#mult
 * Multiply two matricies together. Note that this isn't
 * commutitive.
 * Or multiply a matrix with a vector
 */
static VALUE rb_matrix_multiply(VALUE self, VALUE other)
{
	Matrix4* mat_self;
	Matrix4* mat_other;
	Matrix4* mat_new;

	Vector* vec_other;
	Vector* vec_new;

	VALUE new_obj;

	GetMatrix4(self, mat_self);

	if (rb_obj_is_kind_of( other, cMatrix4 ))
	{
		GetMatrix4(other, mat_other);

		new_obj = NewMatrix4(CLASS_OF(self), mat_new);

		r3d_matrix4_multiply(mat_new, mat_self, mat_other);
	}
	else if (rb_obj_is_kind_of( other, cVector ))
	{
		GetVector(other, vec_other);
		new_obj = NewVector(CLASS_OF(other), vec_new);

		r3d_matrix4_multiply_vector(vec_new, mat_self, vec_other);
	}
	else
	{
		rb_raise(rb_eTypeError, "Expected Matrix4 or Vector, got %s",
				rb_class2name(CLASS_OF(other)));
	}

	return new_obj;
}

/**
 * Ruby3d::Matrix4#get_element
 * Get a given element of the matrix
 */
static VALUE rb_matrix_get_element(VALUE self, VALUE row, VALUE col)
{
	Matrix4* mat_self;
	int c_row, c_col;

	if (!rb_obj_is_kind_of(row, rb_cNumeric) || 
			!rb_obj_is_kind_of(col, rb_cNumeric))
	{
		rb_raise(rb_eTypeError,"Expected Numerics but received %s and %s",
				rb_class2name(CLASS_OF(row)),
				rb_class2name(CLASS_OF(col)));
	}

	c_row = NUM2INT(row);
	c_col = NUM2INT(col);

	if (c_col > 3 || c_col < 0)
	{
		rb_raise( rb_eIndexError, "Column index out of bounds: %d (0-3)",
				c_col );
	}
	else if (c_row > 3 || c_row < 0)
	{
		rb_raise( rb_eIndexError, "Row index out of bounds: %d (0-3)",
				c_row );
	}

	GetMatrix4(self, mat_self);

	return rb_float_new(ELM(*mat_self, c_row, c_col));
}

/**
 * Ruby3d::Matrix4#set_element
 * Set a given element of the matrix
 */
static VALUE rb_matrix_set_element(VALUE self, VALUE row, VALUE col, VALUE val)
{
	Matrix4* mat_self;
	int c_row, c_col;

	if (!rb_obj_is_kind_of(row, rb_cNumeric) || 
			!rb_obj_is_kind_of(col, rb_cNumeric) || 
			!rb_obj_is_kind_of(val, rb_cNumeric))
	{
		rb_raise(rb_eTypeError,
				"Expected Numerics but received row(%s), col(%s), and val(%s)",
				rb_class2name(CLASS_OF(row)),
				rb_class2name(CLASS_OF(col)),
				rb_class2name(CLASS_OF(val)));
	}

	c_row = NUM2INT(row);
	c_col = NUM2INT(col);

	if (c_col > 3 || c_col < 0)
	{
		rb_raise( rb_eIndexError, "Column index out of bounds: %d (0-3)",
				c_col );
	}
	else if (c_row > 3 || c_row < 0)
	{
		rb_raise( rb_eIndexError, "Row index out of bounds: %d (0-3)",
				c_row );
	}

	GetMatrix4(self, mat_self);
	ELM(*mat_self, c_row, c_col) = NUM2FLT(val);

	return self;
}

/**
 * Ruby3d::Matrix4#transpose
 * Returns the transpose of this matrix
 */
static VALUE rb_matrix_transpose(VALUE self)
{
	Matrix4* rot;
	Matrix4* rot_new;
	VALUE new_obj;

	GetMatrix4(self, rot);
	new_obj = NewMatrix4(CLASS_OF(self), rot_new);

	r3d_matrix4_transpose(rot_new, rot);

	return new_obj;
}

/**
 * Ruby3d::Matrix4#equal
 * Checks if two matricies are equal
 */
static VALUE rb_matrix_equal(VALUE self, VALUE other)
{
	Matrix4* mat_self;
	Matrix4* mat_other;
	int i;

	if (!rb_obj_is_kind_of(other, cMatrix4))
	{
		rb_raise(rb_eTypeError, "Expected Matrix4, got a %s", 
				rb_class2name(CLASS_OF(other)));
	}

	GetMatrix4(self, mat_self);
	GetMatrix4(other, mat_other);

	for(i = 0; i < 16; i++)
	{
		if ((*mat_self)[i] != (*mat_other)[i])
		{
			return Qfalse;
		}
	}

	return Qtrue;
}

/**
 * Ruby3d::Matrix4#negate
 * Negates every element of the matrix
 */
static VALUE rb_matrix_negate(VALUE self)
{
	Matrix4* mat;
	Matrix4* mat_new;
	VALUE new_obj;

	GetMatrix4(self, mat);
	new_obj = NewMatrix4(CLASS_OF(self), mat_new);

	r3d_matrix4_negate(mat_new, mat);

	return new_obj;
}

/**
 * Ruby3d::Matrix4#to_s
 * Stringify this matrix
 */
static VALUE rb_matrix_print(VALUE self)
{
	Matrix4* mat;
	int row, col, len;
	VALUE str;
	char buf[20];

	GetMatrix4(self, mat);

	str = rb_str_new2("Matrix4: \n");

	for(row = 0; row < 4; row++)
	{
		str = rb_str_cat(str, "\t[ ", 3);
		for(col = 0; col < 4; col++)
		{
			len = snprintf(buf, 20, "%f ", ELM(*mat, row, col));
			str = rb_str_cat(str, buf, len);
		}
		str = rb_str_cat(str, "]\n", 2);
	}

	return str;
}

/************************************
 * Rotation definitions
 * This is defined as a Quaternion with methods to allow use of 
 * euler values
 ************************************/

/**
 * Ruby3d::Rotation#from_axes
 * Recreate this rotation from the given 3 axes
 */
static VALUE rb_rotation_from_axes(VALUE self, VALUE x, VALUE y, VALUE z)
{
	Vector* xAxis;
	Vector* yAxis;
	Vector* zAxis;
	Rotation* rot;

	if (!rb_obj_is_kind_of(x, cVector) ||
			!rb_obj_is_kind_of(y, cVector) ||
			!rb_obj_is_kind_of(z, cVector)) 
	{
		rb_raise(rb_eTypeError, "Expected 3 Vectors, got: %s, %s, %s",
				rb_class2name(CLASS_OF(x)),
				rb_class2name(CLASS_OF(y)),
				rb_class2name(CLASS_OF(z)));
	}

	GetRotation(self, rot);
	GetVector(x, xAxis);
	GetVector(y, yAxis);
	GetVector(z, zAxis);

	r3d_rotation_from_axes(rot, xAxis, yAxis, zAxis);

	return self;
}

/**
 * Ruby3d::Rotation#from_matrix4
 * Recreate this quaternion given a rotation matrix
 */
static VALUE rb_rotation_from_matrix4(VALUE self, VALUE matrix)
{
	Rotation* rot;
	Matrix4* mat;

	if (!rb_obj_is_kind_of(matrix, cMatrix4))
	{
		rb_raise(rb_eTypeError, "Expected a Matrix4, got %s",
				rb_class2name(CLASS_OF(matrix)));
	}

	GetRotation(self, rot);
	GetMatrix4(matrix, mat);	

	r3d_rotation_from_matrix4(rot, mat);

	return self;
}

/**
 * Ruby3d::Rotation#from_axis_angle
 * Create this quaternion from a given angle and an axis
 */
static VALUE rb_rotation_from_axis_angle(VALUE self, VALUE axis, VALUE angle)
{
	Vector* vec_axis;
	Rotation* rot;
	float fAngle;

	if (!rb_obj_is_kind_of(axis, cVector) || 
			!rb_obj_is_kind_of(angle, rb_cNumeric))
	{
		rb_raise(rb_eTypeError, "Expected Angle, Vector but got %s, %s",
				rb_class2name(CLASS_OF(angle)),
				rb_class2name(CLASS_OF(axis)));
	}

	GetRotation(self, rot);
	GetVector(axis, vec_axis);
	fAngle = NUM2FLT(angle);	

	r3d_rotation_from_axis_angle(rot, vec_axis, fAngle);

	return self;
}

/**
 * Ruby3d::Rotation#new
 * ---
 * Accepts these paramters:
 * 		() - Unit quaternion
 * 		(Matrix4) [rotation matrix]
 *    (vector, vector, vector) [vectors are the axes]
 * 		(vector, angle)
 * 		(x, y, z, angle)
 */
static VALUE rb_rotation_new(int argc, VALUE* argv, VALUE class)
{
	VALUE new_obj;
	Rotation* rot;
	Vector* vec1;
	Vector* vec2;
	Vector* vec3;
	Matrix4* mat;
	int i;

	new_obj = NewRotation(class, rot);

	if (argc == 0)
	{
		// Identity quaternion
		rot->x = 0.0;
		rot->y = 0.0;
		rot->z = 0.0;
		rot->w = 1.0;
	}
	else if (argc == 1)
	{
		// Matrix input
		new_obj = rb_rotation_from_matrix4(new_obj, argv[0]);
	}
	else if (argc == 2)
	{
		// Axis Angle input
		new_obj = rb_rotation_from_axis_angle(new_obj, argv[0], argv[1]);
	}
	else if (argc == 3)
	{
		// 3 Vector input
		new_obj = rb_rotation_from_axes(new_obj, argv[0], argv[1], argv[2]);
	}
	else if (argc == 4)
	{
		// given all four values explicitly
		for(i = 0; i < 4; i++)
		{
			if (!rb_obj_is_kind_of(argv[i], rb_cNumeric))
			{
				rb_raise(rb_eTypeError, "Argument %i was not Numeric but was %s", 
						i, rb_class2name(CLASS_OF(argv[i])));
			}
			else
			{
				rot->x = NUM2FLT(argv[0]);
				rot->y = NUM2FLT(argv[1]);
				rot->z = NUM2FLT(argv[2]);
				rot->w = NUM2FLT(argv[3]);
			}
		}

	}

	return new_obj;
}

/**
 * Ruby3d::Rotation#to_axes
 * Returns an array of the axes associated with this quaternion:
 * 		[ xAxis, yAxis, zAxis ]
 */
static VALUE rb_rotation_to_axes(VALUE self)
{
	Vector* xAxis;
	Vector* yAxis;
	Vector* zAxis;
	Rotation* rot;

	VALUE new_obj, x, y, z;

	new_obj = rb_ary_new2(3);
	GetRotation(self, rot);

	x = NewVector(cVector, xAxis);
	y = NewVector(cVector, yAxis);
	z = NewVector(cVector, zAxis);

	r3d_rotation_to_axes(rot, xAxis, yAxis, zAxis);

	rb_ary_push(new_obj, x);
	rb_ary_push(new_obj, y);
	rb_ary_push(new_obj, z);

	return new_obj;
}

/**
 * Ruby3d::Rotation#normalize
 * Unitize this rotation
 */
static VALUE rb_rotation_normalize(VALUE self)
{
	Rotation* rot;

	GetRotation(self, rot);

	r3d_rotation_normalize(rot);

	return self;
}

/**
 * Ruby3d::Rotation#x
 */
static VALUE rb_rotation_get_x(VALUE self)
{
	Rotation* rot;
	GetRotation(self, rot);
	return rb_float_new(rot->x);	
}

/**
 * Ruby3d::Rotation#y
 */
static VALUE rb_rotation_get_y(VALUE self)
{
	Rotation* rot;
	GetRotation(self, rot);
	return rb_float_new(rot->y);	
}

/**
 * Ruby3d::Rotation#z
 */
static VALUE rb_rotation_get_z(VALUE self)
{
	Rotation* rot;
	GetRotation(self, rot);
	return rb_float_new(rot->z);	
}

/**
 * Ruby3d::Rotation#w
 */
static VALUE rb_rotation_get_w(VALUE self)
{
	Rotation* rot;
	GetRotation(self, rot);
	return rb_float_new(rot->w);	
}

/**
 * Ruby3d::Rotation#x=
 */
static VALUE rb_rotation_set_x(VALUE self, VALUE val)
{
	Rotation* rot;
	GetRotation(self, rot);
	rot->x = NUM2FLT(val);
	return self;	
}

/**
 * Ruby3d::Rotation#y=
 */
static VALUE rb_rotation_set_y(VALUE self, VALUE val)
{
	Rotation* rot;
	GetRotation(self, rot);
	rot->y = NUM2FLT(val);
	return self;	
}

/**
 * Ruby3d::Rotation#z=
 */
static VALUE rb_rotation_set_z(VALUE self, VALUE val)
{
	Rotation* rot;
	GetRotation(self, rot);
	rot->z = NUM2FLT(val);
	return self;	
}

/**
 * Ruby3d::Rotation#w=
 */
static VALUE rb_rotation_set_w(VALUE self, VALUE val)
{
	Rotation* rot;
	GetRotation(self, rot);
	rot->w = NUM2FLT(val);
	return self;	
}

/**
 * Ruby3d::Rotation#roll
 * Returns the roll value of this rotation
 */
static VALUE rb_rotation_get_roll(VALUE self)
{
	Rotation* rot;
	float roll;

	GetRotation(self, rot);

	r3d_rotation_get_roll(&roll, rot);

	return rb_float_new(roll);
}

/**
 * Ruby3d::Rotation#yaw
 * Returns the yaw value of this rotation
 */
static VALUE rb_rotation_get_yaw(VALUE self)
{
	Rotation* rot;
	float yaw;

	GetRotation(self, rot);

	r3d_rotation_get_roll(&yaw, rot);

	return rb_float_new(yaw);
}

/**
 * Ruby3d::Rotation#pitch
 * Returns the pitch value of this rotation
 */
static VALUE rb_rotation_get_pitch(VALUE self)
{
	Rotation* rot;
	float pitch;

	GetRotation(self, rot);

	r3d_rotation_get_pitch(&pitch, rot);

	return rb_float_new(pitch);
}

/**
 * Ruby3d::Rotation#rotate roll, pitch, yaw
 * Use Euler values to rotate the quaternion
 * Values in degrees
 * Please note: This library assumes +Z is up, so:
 *
 * Pitch = x-axis
 * Roll = y-axis
 * Yaw = z-axis
 */
static VALUE rb_rotation_rotate(VALUE self, VALUE roll, VALUE pitch, VALUE yaw)
{
	Rotation* rot;
	float fRoll, fPitch, fYaw;

	if (!rb_obj_is_kind_of(roll, rb_cNumeric) || 
			!rb_obj_is_kind_of(pitch, rb_cNumeric) || 
			!rb_obj_is_kind_of(yaw, rb_cNumeric))
	{
		rb_raise(rb_eTypeError, "Expected 3 Numerics, got %s, %s, %s",
				rb_class2name(CLASS_OF(roll)),
				rb_class2name(CLASS_OF(pitch)),
				rb_class2name(CLASS_OF(yaw)));
	}

	GetRotation(self, rot);

	fRoll = NUM2FLT(roll);
	fPitch = NUM2FLT(pitch);
	fYaw = NUM2FLT(yaw);

	r3d_rotation_rotate(rot, fRoll, fPitch, fYaw);

	return self;
}

/**
 * Ruby3d::Rotation#to_matrix4
 * Convert the quaternion into a rotation matrix
 */
static VALUE rb_rotation_to_matrix4(VALUE self)
{
	Rotation* rot;
	Matrix4* mat;
	VALUE new_obj;

	GetRotation(self, rot);
	new_obj = NewMatrix4(cMatrix4, mat);

	r3d_rotation_to_matrix4(mat, rot);

	return new_obj;
}

/**
 * Ruby3d::Rotation#equal?
 * Check if two quaternions are equal
 */
static VALUE rb_rotation_equal(VALUE self, VALUE other)
{
	Rotation* rot_self;
	Rotation* rot_other;

	if (!rb_obj_is_kind_of(other, cRotation))
	{
		rb_raise(rb_eTypeError, "Expected Rotation, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	GetRotation(self, rot_self);
	GetRotation(other, rot_other);

	if (rot_self->x == rot_other->x &&
			rot_self->y == rot_other->y &&
			rot_self->z == rot_other->z &&
			rot_self->w == rot_other->w)
	{
		return Qtrue;
	}
	else
	{
		return Qfalse;
	}
}

/**
 * Ruby3d::Rotation#add
 * Add two quaternions together
 */
static VALUE rb_rotation_add(VALUE self, VALUE other)
{
	Rotation* rot_self;
	Rotation* rot_other;
	Rotation* rot_new;
	VALUE new_obj;

	if (!rb_obj_is_kind_of(other, cRotation))
	{
		rb_raise(rb_eTypeError, "Expected Rotation, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	GetRotation(self, rot_self);
	GetRotation(other, rot_other);
	new_obj = NewRotation(cRotation, rot_new);

	r3d_rotation_add(rot_new, rot_self, rot_other);

	return new_obj;
}

/**
 * Ruby3d::Rotation#subtract
 * Subtracts two quaternions together
 */
static VALUE rb_rotation_subtract(VALUE self, VALUE other)
{
	Rotation* rot_self;
	Rotation* rot_other;
	Rotation* rot_new;
	VALUE new_obj;

	if (!rb_obj_is_kind_of(other, cRotation))
	{
		rb_raise(rb_eTypeError, "Expected Rotation, got %s", 
				rb_class2name(CLASS_OF(other)));
	}

	GetRotation(self, rot_self);
	GetRotation(other, rot_other);
	new_obj = NewRotation(cRotation, rot_new);

	r3d_rotation_subtract(rot_new, rot_self, rot_other);

	return new_obj;
}

/**
 * Ruby3d::Rotation#multiply
 * Multipliess two quaternions together or multiplies
 * a quaternion by a scalar or multiplies a quaternion by a vector, returning
 * a vector
 */
static VALUE rb_rotation_multiply(VALUE self, VALUE other)
{
	Rotation* rot_self;
	Rotation* rot_other;
	Vector* vec_other;
	Rotation* rot_new;
	Vector* vec_new;
	float value;
	VALUE new_obj = Qnil;

	GetRotation(self, rot_self);

	if (rb_obj_is_kind_of(other, cRotation))
	{
		GetRotation(other, rot_other);
		new_obj = NewRotation(cRotation, rot_new);
		r3d_rotation_multiply_rotation(rot_new, rot_self, rot_other);
	}
	else if (rb_obj_is_kind_of(other, cVector))
	{
		GetVector(other, vec_other);
		new_obj = NewVector(cVector, vec_new);
		r3d_rotation_multiply_vector(vec_new, rot_self, vec_other);
	}
	else if (rb_obj_is_kind_of(other, rb_cNumeric))
	{
		value = NUM2FLT(other);
		new_obj = NewRotation(cRotation, rot_new);
		r3d_rotation_multiply_scalar(rot_new, rot_self, value);
	}
	else
	{
		rb_raise(rb_eTypeError, "Expected Rotation, Vector, or Numeric, recieved %s",
				rb_class2name(CLASS_OF(other)));
	}

	return new_obj;
}

/**
 * Ruby3d::Rotation#dot
 * Calculate the dot product of the quaternion to another quaternion
 */
static VALUE rb_rotation_dot(VALUE self, VALUE other)
{
	Rotation* rot_self;
	Rotation* rot_other;
	float value;

	if (!rb_obj_is_kind_of(other, cRotation))
	{
		rb_raise(rb_eTypeError, "Expected Rotation, received %s",
				rb_class2name(CLASS_OF(other)));
	}

	GetRotation(self, rot_self);
	GetRotation(other, rot_other);

	r3d_rotation_dot(&value, rot_self, rot_other);

	return rb_float_new(value);
}

/**
 * Ruby3d::Rotation#norm
 * Returns the squared length of the quaternion
 */
static VALUE rb_rotation_norm(VALUE self)
{
	Rotation* rot_self;
	float value;

	GetRotation(self, rot_self);

	r3d_rotation_norm(&value, rot_self);

	return rb_float_new(value);
}

/**
 * Ruby3d::Rotation#inverse
 * Returns an inverted copy of the quaternion
 */
static VALUE rb_rotation_inverse(VALUE self)
{
	Rotation* rot_self;
	Rotation* rot_new;
	VALUE new_obj;
	float value;

	GetRotation(self, rot_self);
	new_obj = NewRotation(cRotation, rot_new);

	r3d_rotation_inverse(rot_new, rot_self);

	return new_obj;
}

/**
 * Ruby3d::Rotation#unit_inverse
 * Inverts a unit quaternion, much faster than above
 */
static VALUE rb_rotation_unit_inverse(VALUE self)
{
	Rotation* rot_self;
	Rotation* rot_new;
	VALUE new_obj;
	float value;

	GetRotation(self, rot_self);
	new_obj = NewRotation(cRotation, rot_new);

	r3d_rotation_unit_inverse(rot_new, rot_self);

	return new_obj;
}

/**
 * Ruby3d::Rotation#exp
 */
static VALUE rb_rotation_exp(VALUE self)
{
	Rotation* rot_self;
	Rotation* rot_new;
	VALUE new_obj;
	float value;

	GetRotation(self, rot_self);
	new_obj = NewRotation(cRotation, rot_new);

	r3d_rotation_exp(rot_new, rot_self);

	return new_obj;
}

/**
 * Ruby3d::Rotation#log
 */
static VALUE rb_rotation_log(VALUE self)
{
	Rotation* rot_self;
	Rotation* rot_new;
	VALUE new_obj;
	float value;

	GetRotation(self, rot_self);
	new_obj = NewRotation(cRotation, rot_new);

	r3d_rotation_log(rot_new, rot_self);

	return new_obj;
}

/**
 * Ruby3d::Rotation#to_s
 * Stringify this rotation
 */
static VALUE rb_rotation_print(VALUE self)
{
	VALUE str, vRoll, vPitch, vYaw;
	Rotation* rot;
	char buf[64];
	int len;
	float roll, pitch, yaw;

	GetRotation(self, rot);
	
//	vRoll = rb_rotation_get_roll(self);
//	vPitch = rb_rotation_get_pitch(self);
//	vYaw = rb_rotation_get_yaw(self);

//	roll = NUM2FLT(vRoll);
//	pitch = NUM2FLT(vPitch);
//	yaw = NUM2FLT(vYaw);

	str = rb_str_new2("Rotation: (");
	len = snprintf(buf, 64, "[%f, %f, %f], %f", rot->x, rot->y, rot->z, rot->w);
	str = rb_str_cat(str, buf, len);
	str = rb_str_cat(str, ")", 1);

//	str = rb_str_new2("Rotation: (");
//	len = snprintf(buf, 64, "%f, %f, %f", roll, pitch, yaw);
//	str = rb_str_cat(str, buf, len);
//	str = rb_str_cat(str, ")", 1);

	return str;
}



void Init_ruby3d()
{

	/*
	 * math3d module
	 */
	mRuby3d = rb_define_module("Ruby3d");
	eInvertError = rb_define_class("InvertError", rb_eRuntimeError);
	rb_define_const(mRuby3d, "IN_NONE", Qfalse);
	rb_define_const(mRuby3d, "IN_MAYBE", INT2FIX(IN_MAYBE));
	rb_define_const(mRuby3d, "IN_ALL", INT2FIX(IN_ALL));

	/*
	 * Vector, the 3D version
	 */
	cVector = rb_define_class_under(mRuby3d, "Vector", rb_cObject);
	rb_define_singleton_method(cVector, "new", rb_vector_new, -1);
	rb_define_method(cVector, "add", rb_vector_add, 1);
	rb_define_alias(cVector, "+", "add");
	rb_define_method(cVector, "subtract", rb_vector_subtract, 1);
	rb_define_alias(cVector, "-", "subtract");
	rb_define_method(cVector, "mult", rb_vector_multiply, 1);
	rb_define_alias(cVector, "*", "mult");
	rb_define_method(cVector, "divide", rb_vector_divide, 1);
	rb_define_alias(cVector, "/", "divide");
	rb_define_method(cVector, "negate", rb_vector_negate, 0);
	rb_define_method(cVector, "x", rb_vector_x, 0);
	rb_define_method(cVector, "y", rb_vector_y, 0);
	rb_define_method(cVector, "z", rb_vector_z, 0);
	rb_define_method(cVector, "x=", rb_vector_set_x, 1);
	rb_define_method(cVector, "y=", rb_vector_set_y, 1);
	rb_define_method(cVector, "z=", rb_vector_set_z, 1);
	rb_define_method(cVector, "dot", rb_vector_dot, 1);
	rb_define_method(cVector, "cross", rb_vector_cross, 1);
	rb_define_method(cVector, "length", rb_vector_length, 0);
	rb_define_method(cVector, "normalize", rb_vector_normalize, 0);
	rb_define_method(cVector, "normalize!", rb_vector_normalize_self, 0);
	rb_define_method(cVector, "equal?", rb_vector_equal, 1);
	rb_define_alias(cVector, "==", "equal?");
	rb_define_method(cVector, "to_s", rb_vector_print, 0);
	rb_define_method(cVector, "rotate_to", rb_vector_rotate_to, 1);

	/**
	 * Matrix4
	 */
	cMatrix4 = rb_define_class_under(mRuby3d, "Matrix4", rb_cObject);
	rb_define_singleton_method(cMatrix4, "new", rb_matrix_new, -1);
	rb_define_method(cMatrix4, "add", rb_matrix_add, 1);
	rb_define_alias(cMatrix4, "+", "add");
	rb_define_method(cMatrix4, "sub", rb_matrix_subtract, 1);
	rb_define_alias(cMatrix4, "-", "sub");
	rb_define_method(cMatrix4, "mult", rb_matrix_multiply, 1);
	rb_define_alias(cMatrix4, "*", "mult");
	rb_define_method(cMatrix4, "get_element",  rb_matrix_get_element, 2);
	rb_define_alias(cMatrix4, "[]", "get_element");
	rb_define_method(cMatrix4, "set_element",  rb_matrix_set_element, 3);
	rb_define_alias(cMatrix4, "[]=", "set_element");
	rb_define_method(cMatrix4, "transpose",  rb_matrix_transpose, 0);
	rb_define_method(cMatrix4, "negate", rb_matrix_negate, 0);
	//rb_define_method(cMatrix4, "to_a", rb_matrix_to_array, 0);
	rb_define_method(cMatrix4, "equal?", rb_matrix_equal, 1);
	rb_define_alias(cMatrix4, "==", "equal?");
	rb_define_method(cMatrix4, "to_s", rb_matrix_print, 0);

	/*
	 * Rotation (as quaternion)
	 */
	cRotation = rb_define_class_under(mRuby3d, "Rotation", rb_cObject);
	rb_define_singleton_method(cRotation, "new", rb_rotation_new, -1);
	rb_define_method(cRotation, "x", rb_rotation_get_x, 0);
	rb_define_method(cRotation, "y", rb_rotation_get_y, 0);
	rb_define_method(cRotation, "z", rb_rotation_get_z, 0);
	rb_define_method(cRotation, "w", rb_rotation_get_w, 0);
	rb_define_method(cRotation, "x=", rb_rotation_set_x, 1);
	rb_define_method(cRotation, "y=", rb_rotation_set_y, 1);
	rb_define_method(cRotation, "z=", rb_rotation_set_z, 1);
	rb_define_method(cRotation, "w=", rb_rotation_set_w, 1);
	rb_define_method(cRotation, "roll", rb_rotation_get_roll, 0);
	rb_define_method(cRotation, "pitch", rb_rotation_get_pitch, 0);
	rb_define_method(cRotation, "yaw", rb_rotation_get_yaw, 0);
	rb_define_method(cRotation, "rotate", rb_rotation_rotate, 3);
	rb_define_method(cRotation, "to_matrix4", rb_rotation_to_matrix4, 0);
	rb_define_method(cRotation, "from_matrix4", rb_rotation_from_matrix4, 1);
	rb_define_method(cRotation, "to_axes", rb_rotation_to_axes, 0);
	rb_define_method(cRotation, "from_axes", rb_rotation_from_axes, 3);
	rb_define_method(cRotation, "from_axis_angle", rb_rotation_from_axis_angle, 2);
	rb_define_method(cRotation, "normalize!", rb_rotation_normalize, 0);
	rb_define_method(cRotation, "equal?", rb_rotation_equal, 1);
	rb_define_alias(cRotation, "==", "equal?");
	rb_define_method(cRotation, "add", rb_rotation_add, 1);
	rb_define_alias(cRotation, "+", "add");
	rb_define_method(cRotation, "subtract", rb_rotation_subtract, 1);
	rb_define_alias(cRotation, "-", "subtract");
	rb_define_method(cRotation, "multiply", rb_rotation_multiply, 1);
	rb_define_alias(cRotation, "*", "multiply");
	rb_define_method(cRotation, "dot", rb_rotation_dot, 1);
	rb_define_method(cRotation, "norm", rb_rotation_norm, 0);
	rb_define_method(cRotation, "inverse", rb_rotation_inverse, 0);
	rb_define_method(cRotation, "unit_inverse", rb_rotation_unit_inverse, 0);
	rb_define_method(cRotation, "exp", rb_rotation_exp, 0);
	rb_define_method(cRotation, "log", rb_rotation_log, 0);
	rb_define_method(cRotation, "to_s", rb_rotation_print, 0);

}

