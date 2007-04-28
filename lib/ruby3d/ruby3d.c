#include "ruby3d.h"

Matrix4 mat_identity = 
{1.f, 0.f, 0.f, 0.f,
 0.f, 1.f, 0.f, 0.f,
 0.f, 0.f, 1.f, 0.f,
 0.f, 0.f, 0.f, 1.f};

Matrix4 mat_zero = 
{0.f, 0.f, 0.f, 0.f,
 0.f, 0.f, 0.f, 0.f,
 0.f, 0.f, 0.f, 0.f,
 0.f, 0.f, 0.f, 0.f};

Vector vec_zero = {0.f, 0.f, 0.f};
Vector vec_unitx = {1.f, 0.f, 0.f};
Vector vec_unity = {0.f, 1.f, 0.f};
Vector vec_unitz = {0.f, 0.f, 1.f};
Vector vec_unit_scale = {1.f, 1.f, 1.f};

Rotation rot_identity = {0.f, 0.f, 0.f, 1.f};

Ray ray_default = { {0.f, 0.f, 0.f}, {0.f, 0.f, -1.f}, 0.f};
Plane plane_default = { 0.f, 1.f, 0.f, 0.f }; /* ax+by+cz=d */
Bound bound_default = { {0.f, 0.f, 0.f}, {-1.f, -1.f, -1.f} };
Frustum frust_default = { -1.f, 1.f, /* near/far */
                         {{ -1.f, 0.f, 0.f, -1.f }, /* left plane */
                          { 1.f, 0.f, 0.f, 1.f }, /* right plane */
                          { 0.f, -1.f, 0.f, -1.f }, /* bottom plane */
                          { 0.f, 1.f, 0.f, 1.f }, /* top plane */
                          { -1.f, 0.f, 0.f, 1.f }, /* far_p plane */
                          { -1.f, 0.f, 0.f, 1.f }}, /* near_p plane */
                         {{-1.f, -1.f, -1.f},    /* near_p low left */
                          {1.f, -1.f, -1.f},    /* near_p low right */
                          {1.f, 1.f, -1.f},    /* near_p high right */
                          {-1.f, 1.f, -1.f},    /* near_p high left */
                          {-1.f, -1.f, 1.f},    /* far_p low left */
                          {1.f, -1.f, 1.f},    /* far_p low right */
                          {1.f, 1.f, 1.f},    /* far_p high right */
                          {-1.f, 1.f, 1.f}}    /* far_p high left */
                        };

