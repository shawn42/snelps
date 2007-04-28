$:.push("../")

require 'test/unit'
require 'ruby3d'

class RotationTest < Test::Unit::TestCase
	include Ruby3d

	def setup
	end

	def teardown
	end

	def test_initialize
		rot = Rotation.new
		
		assert_equal 0.0, rot.x
		assert_equal 0.0, rot.y
		assert_equal 0.0, rot.z
		assert_equal 1.0, rot.w

		mat = Matrix4.new(
			[1, 1, 1, 0,
			 1, 1, 1, 0,
			 1, 1, 1, 0, 
			 0, 0, 0, 1] )
		rot = Rotation.new mat
		
		assert_equal 0.0, rot.x
		assert_equal 0.0, rot.y
		assert_equal 0.0, rot.z
		assert_equal 1.0, rot.w

		rot = Rotation.new(Vector.new(1,0,5), 10)

		assert_in_delta -0.958924, rot.x, 0.00001
		assert_in_delta 0.0, rot.y, 0.00001
		assert_in_delta -4.794621, rot.z, 0.00001
		assert_in_delta 0.283662, rot.w, 0.00001

		rot = Rotation.new 1, 5, 7, 10

		assert_equal 1.0, rot.x
		assert_equal 5.0, rot.y
		assert_equal 7.0, rot.z
		assert_equal 10.0, rot.w
	end

	def test_from_to_axes
		x = Vector.new 1,0,0
		y = Vector.new 0,1,0
		z = Vector.new 0,0,1

		rot = Rotation.new x, y, z

		got = rot.to_axes

		assert_equal x, got[0]
		assert_equal y, got[1]
		assert_equal z, got[2]
	end

	def test_get_x
		rot = Rotation.new 1, 5, 7, 10
		assert_equal 1.0, rot.x
	end

	def test_get_y
		rot = Rotation.new 1, 5, 7, 10
		assert_equal 5.0, rot.y
	end

	def test_get_z
		rot = Rotation.new 1, 5, 7, 10
		assert_equal 7.0, rot.z
	end

	def test_get_w
		rot = Rotation.new 1, 5, 7, 10
		assert_equal 10.0, rot.w
	end

	def test_set_x
		rot = Rotation.new 1, 5, 7, 10
		rot.x = 10.0
		assert_equal 10.0, rot.x
	end

	def test_set_y
		rot = Rotation.new 1, 5, 7, 10
		rot.y = 10.0
		assert_equal 10.0, rot.y
	end

	def test_set_z
		rot = Rotation.new 1, 5, 7, 10
		rot.z = 10.0
		assert_equal 10.0, rot.z
	end

	def test_set_w
		rot = Rotation.new 1, 5, 7, 10
		rot.w = 10.0
		assert_equal 10.0, rot.w
	end

	def test_rotate
		rot = Rotation.new
		rot.rotate 100, 50, 0

		assert_in_delta 0.27165, rot.x, 0.00001
		assert_in_delta 0.69427, rot.y, 0.00001
		assert_in_delta -0.32374, rot.z, 0.00001
		assert_in_delta 0.58256, rot.w, 0.00001
	end

	def test_to_matrix4
		rot = Rotation.new 1,1,1, 100
		matrix = rot.to_matrix4
		
		expected = Matrix4.new([-3.0, -198.0, 202.0, 0.0,
														202.0, -3.0, -198.0, 0.0,
														-198.0, 202.0, -3.0, 0.0,
														0.0, 0.0, 0.0, 1.0])

		assert_equal expected, matrix
	end

	def test_equal
		rot1 = Rotation.new 1, 1, 1, 1
		rot2 = Rotation.new 1, 1, 1, 1
		rot3 = Rotation.new 2, 2, 2, 2

		assert rot1 == rot2
		assert !(rot1 == rot3)
		assert !rot2.equal?(rot3)
	end

	def test_add
		rot1 = Rotation.new 1,1,1,1
		rot2 = Rotation.new 2,2,2,2
		expected = Rotation.new 3,3,3,3

		got = rot1 + rot2
		assert_equal expected, got
	end

	def test_subtract
		rot1 = Rotation.new 1,1,1,1
		rot2 = Rotation.new 2,2,2,2
		expected = Rotation.new 1,1,1,1

		got = rot2 - rot1
		assert_equal expected, got
	end

	def test_multiply_scalar
		rot = Rotation.new 1,1,1,1
		expected = Rotation.new 3,3,3,3

		got = rot * 3

		assert_equal expected, got
	end

	def test_multiply_rotation
		rot1 = Rotation.new 1,1,1,1
		rot2 = Rotation.new 2,2,2,2
		expected = Rotation.new 4,4,4,-4

		got = rot1 * rot2

		assert_equal expected, got
	end

	def test_multiply_vector
		rot = Rotation.new 1,3,1,1
		vec = Vector.new 2,2,2
		expected = Vector.new -14, 18, -30 

		got = rot * vec

		assert_equal expected, got
	end

	def test_dot
		rot1 = Rotation.new 1,1,1,1
		rot2 = Rotation.new 2,2,2,2
		expected = 1*2 + 1*2 + 1*2 + 1*2

		got = rot1.dot rot2 

		assert_equal expected, got
	end

	def test_norm
		rot = Rotation.new 1,1,1,1
		expected = 4

		got = rot.norm

		assert_equal expected, got
	end

	def test_inverse
		rot = Rotation.new 1,1,1,1
		expected = Rotation.new 0.25, 0.25, 0.25, 0.25 

		got = rot.inverse

		assert_equal expected, got
	end

	def test_unit_inverse
		rot = Rotation.new 1,1,1,1
		expected = Rotation.new -1,-1,-1,1

		got = rot.unit_inverse

		assert_equal expected, got
	end

	def test_exp
		rot = Rotation.new 1,2,3, 10

		got = rot.exp

		assert_in_delta -0.150921, got.x, 0.00001
		assert_in_delta -0.301843, got.y, 0.00001
		assert_in_delta -0.452764, got.z, 0.00001
		assert_in_delta -0.825299, got.w, 0.00001
	end

	def test_log
		rot = Rotation.new 1,2,3, 10
		expected = Rotation.new 1, 2, 3, 0

		got = rot.log

		assert_equal expected, got
	end

end
