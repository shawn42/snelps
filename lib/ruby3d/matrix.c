/**
 * Matrix4 definitions
 */

#include "ruby3d.h"

void r3d_matrix4_add(Matrix4* result, Matrix4* self, Matrix4* other)
{
	ELM(*result,0,0) = ELM(*self,0,0) + ELM(*other,0,0);
	ELM(*result,0,1) = ELM(*self,0,1) + ELM(*other,0,1);
	ELM(*result,0,2) = ELM(*self,0,2) + ELM(*other,0,2);
	ELM(*result,0,3) = ELM(*self,0,3) + ELM(*other,0,3);

	ELM(*result,1,0) = ELM(*self,1,0) + ELM(*other,1,0);
	ELM(*result,1,1) = ELM(*self,1,1) + ELM(*other,1,1);
	ELM(*result,1,2) = ELM(*self,1,2) + ELM(*other,1,2);
	ELM(*result,1,3) = ELM(*self,1,3) + ELM(*other,1,3);

	ELM(*result,2,0) = ELM(*self,2,0) + ELM(*other,2,0);
	ELM(*result,2,1) = ELM(*self,2,1) + ELM(*other,2,1);
	ELM(*result,2,2) = ELM(*self,2,2) + ELM(*other,2,2);
	ELM(*result,2,3) = ELM(*self,2,3) + ELM(*other,2,3);

	ELM(*result,3,0) = ELM(*self,3,0) + ELM(*other,3,0);
	ELM(*result,3,1) = ELM(*self,3,1) + ELM(*other,3,1);
	ELM(*result,3,2) = ELM(*self,3,2) + ELM(*other,3,2);
	ELM(*result,3,3) = ELM(*self,3,3) + ELM(*other,3,3);
}

void r3d_matrix4_subtract(Matrix4* result, Matrix4* self, Matrix4* other)
{
	ELM(*result,0,0) = ELM(*self,0,0) - ELM(*other,0,0);
	ELM(*result,0,1) = ELM(*self,0,1) - ELM(*other,0,1);
	ELM(*result,0,2) = ELM(*self,0,2) - ELM(*other,0,2);
	ELM(*result,0,3) = ELM(*self,0,3) - ELM(*other,0,3);

	ELM(*result,1,0) = ELM(*self,1,0) - ELM(*other,1,0);
	ELM(*result,1,1) = ELM(*self,1,1) - ELM(*other,1,1);
	ELM(*result,1,2) = ELM(*self,1,2) - ELM(*other,1,2);
	ELM(*result,1,3) = ELM(*self,1,3) - ELM(*other,1,3);

	ELM(*result,2,0) = ELM(*self,2,0) - ELM(*other,2,0);
	ELM(*result,2,1) = ELM(*self,2,1) - ELM(*other,2,1);
	ELM(*result,2,2) = ELM(*self,2,2) - ELM(*other,2,2);
	ELM(*result,2,3) = ELM(*self,2,3) - ELM(*other,2,3);

	ELM(*result,3,0) = ELM(*self,3,0) - ELM(*other,3,0);
	ELM(*result,3,1) = ELM(*self,3,1) - ELM(*other,3,1);
	ELM(*result,3,2) = ELM(*self,3,2) - ELM(*other,3,2);
	ELM(*result,3,3) = ELM(*self,3,3) - ELM(*other,3,3);
}

void r3d_matrix4_multiply(Matrix4* result, Matrix4* self, Matrix4* other)
{
	ELM(*result,0,0) = ELM(*self,0,0) * ELM(*other,0,0) + ELM(*self,0,1) * ELM(*other,1,0) + ELM(*self,0,2) * ELM(*other,2,0) + ELM(*self,0,3) * ELM(*other,3,0);
	ELM(*result,0,1) = ELM(*self,0,0) * ELM(*other,0,1) + ELM(*self,0,1) * ELM(*other,1,1) + ELM(*self,0,2) * ELM(*other,2,1) + ELM(*self,0,3) * ELM(*other,3,1);
	ELM(*result,0,2) = ELM(*self,0,0) * ELM(*other,0,2) + ELM(*self,0,1) * ELM(*other,1,2) + ELM(*self,0,2) * ELM(*other,2,2) + ELM(*self,0,3) * ELM(*other,3,2);
	ELM(*result,0,3) = ELM(*self,0,0) * ELM(*other,0,3) + ELM(*self,0,1) * ELM(*other,1,3) + ELM(*self,0,2) * ELM(*other,2,3) + ELM(*self,0,3) * ELM(*other,3,3);

	ELM(*result,1,0) = ELM(*self,1,0) * ELM(*other,0,0) + ELM(*self,1,1) * ELM(*other,1,0) + ELM(*self,1,2) * ELM(*other,2,0) + ELM(*self,1,3) * ELM(*other,3,0);
	ELM(*result,1,1) = ELM(*self,1,0) * ELM(*other,0,1) + ELM(*self,1,1) * ELM(*other,1,1) + ELM(*self,1,2) * ELM(*other,2,1) + ELM(*self,1,3) * ELM(*other,3,1);
	ELM(*result,1,2) = ELM(*self,1,0) * ELM(*other,0,2) + ELM(*self,1,1) * ELM(*other,1,2) + ELM(*self,1,2) * ELM(*other,2,2) + ELM(*self,1,3) * ELM(*other,3,2);
	ELM(*result,1,3) = ELM(*self,1,0) * ELM(*other,0,3) + ELM(*self,1,1) * ELM(*other,1,3) + ELM(*self,1,2) * ELM(*other,2,3) + ELM(*self,1,3) * ELM(*other,3,3);

	ELM(*result,2,0) = ELM(*self,2,0) * ELM(*other,0,0) + ELM(*self,2,1) * ELM(*other,1,0) + ELM(*self,2,2) * ELM(*other,2,0) + ELM(*self,2,3) * ELM(*other,3,0);
	ELM(*result,2,1) = ELM(*self,2,0) * ELM(*other,0,1) + ELM(*self,2,1) * ELM(*other,1,1) + ELM(*self,2,2) * ELM(*other,2,1) + ELM(*self,2,3) * ELM(*other,3,1);
	ELM(*result,2,2) = ELM(*self,2,0) * ELM(*other,0,2) + ELM(*self,2,1) * ELM(*other,1,2) + ELM(*self,2,2) * ELM(*other,2,2) + ELM(*self,2,3) * ELM(*other,3,2);
	ELM(*result,2,3) = ELM(*self,2,0) * ELM(*other,0,3) + ELM(*self,2,1) * ELM(*other,1,3) + ELM(*self,2,2) * ELM(*other,2,3) + ELM(*self,2,3) * ELM(*other,3,3);

	ELM(*result,3,0) = ELM(*self,3,0) * ELM(*other,0,0) + ELM(*self,3,1) * ELM(*other,1,0) + ELM(*self,3,2) * ELM(*other,2,0) + ELM(*self,3,3) * ELM(*other,3,0);
	ELM(*result,3,1) = ELM(*self,3,0) * ELM(*other,0,1) + ELM(*self,3,1) * ELM(*other,1,1) + ELM(*self,3,2) * ELM(*other,2,1) + ELM(*self,3,3) * ELM(*other,3,1);
	ELM(*result,3,2) = ELM(*self,3,0) * ELM(*other,0,2) + ELM(*self,3,1) * ELM(*other,1,2) + ELM(*self,3,2) * ELM(*other,2,2) + ELM(*self,3,3) * ELM(*other,3,2);
	ELM(*result,3,3) = ELM(*self,3,0) * ELM(*other,0,3) + ELM(*self,3,1) * ELM(*other,1,3) + ELM(*self,3,2) * ELM(*other,2,3) + ELM(*self,3,3) * ELM(*other,3,3);

}

void r3d_matrix4_multiply_vector(Vector* result, Matrix4* self, Vector* other)
{
	result->x = ( ELM(*self, 0, 0) * other->x + ELM(*self, 0, 1) * other->y + ELM(*self, 0, 2) * other->z + ELM(*self, 0, 3) ) * 1.0;
	result->y = ( ELM(*self, 1, 0) * other->x + ELM(*self, 1, 1) * other->y + ELM(*self, 1, 2) * other->z + ELM(*self, 1, 3) ) * 1.0;
	result->z = ( ELM(*self, 2, 0) * other->x + ELM(*self, 2, 1) * other->y + ELM(*self, 2, 2) * other->z + ELM(*self, 2, 3) ) * 1.0;
}

void r3d_matrix4_transpose(Matrix4* result, Matrix4* self)
{
	int row, col;

	for (row = 0; row < 4; row++)
	{
		for (col = 0; col < 4; col++)
		{
			ELM(*result, row, col) = ELM(*self, col, row);
		}
	}
}

void r3d_matrix4_negate(Matrix4* result, Matrix4* self)
{
	int row, col;

	for (row = 0; row < 4; row++)
	{
		for (col = 0; col < 4; col++)
		{
			ELM(*result,row,col) = ELM(*self,row,col) * -1;
		}
	}
}
