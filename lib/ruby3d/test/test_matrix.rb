$:.push("../")

require 'test/unit'
require 'ruby3d'

class MatrixTest < Test::Unit::TestCase
	include Ruby3d

	def setup
	end

	def teardown
	end

	def test_initialize
		mat = Matrix4.new
		4.times do |i|
			4.times do |j|
				assert_equal 0, mat[i,j]
			end
		end

		val = [1,1,1,1, 0,0,0,0, 2,2,2,2, 3,3,3,3]
		mat = Matrix4.new val

		4.times do |i|
			4.times do |j|
				assert_equal val[i * 4 + j], mat[i,j]
			end
		end
	end

	def test_add
		val = [1,1,1,1, 0,0,0,0, 2,2,2,2, 3,3,3,3]
		mat1 = Matrix4.new
		mat2 = Matrix4.new val

		got = mat1 + mat2

		4.times do |i|
			4.times do |j|
				assert_equal val[i*4 + j], got[i,j]
			end
		end
	end

	def test_sub
		val = [1,1,1,1, 0,0,0,0, 2,2,2,2, 3,3,3,3]
		mat1 = Matrix4.new
		mat2 = Matrix4.new val

		got = mat2 - mat1

		4.times do |i|
			4.times do |j|
				assert_equal val[i*4 + j], got[i,j]
			end
		end
	end

	def test_mult_matrix
		val = [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
		mat1 = Matrix4.new val
		mat2 = Matrix4.new val

		expected = Matrix4.new([
				10, 20, 30, 40,
				10, 20, 30, 40,
				10, 20, 30, 40,
				10, 20, 30, 40,
				]);

		got = mat1 * mat2

		4.times do |i|
			4.times do |j|
				assert_equal expected[i,j], got[i,j]
			end
		end
	end

	def test_mult_vector
		val = [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
		mat = Matrix4.new val
		vec = Vector.new 2, 2, 2

		got = mat * vec

		assert_equal 16, got.x
		assert_equal 16, got.y
		assert_equal 16, got.z
	end

	def test_get_element
		val = [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
		mat = Matrix4.new val

		assert_equal 1, mat[0,0]
		assert_equal 4, mat[3,3]
		assert_equal 3, mat[1,2]
	end

	def test_set_element
		mat = Matrix4.new
		mat[1,1] = 10
		mat[2,2] = 100
		mat[3,2] = 34
		mat[1,2] = 30

		assert_equal 10, mat[1,1]
		assert_equal 100, mat[2,2]
		assert_equal 34, mat[3,2]
		assert_equal 30, mat[1,2]
	end

	def test_equal
		val = [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
		mat1 = Matrix4.new val
		mat2 = Matrix4.new val
		mat3 = Matrix4.new 

		assert mat1 == mat2
		assert !(mat1 == mat3)
		assert !mat2.equal?(mat3)
	end

	def test_negate
		val = [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4]
		nVal = [ -1, -2, -3, -4, -1, -2, -3, -4, -1, -2, -3, -4, -1, -2, -3, -4]
		mat = Matrix4.new val
		expected = Matrix4.new nVal

		got = mat.negate
		assert_equal expected, got
	end

end
