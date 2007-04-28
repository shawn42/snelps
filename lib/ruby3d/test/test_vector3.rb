$:.push("../")

require 'test/unit'
require 'ruby3d'

class VectorTest < Test::Unit::TestCase
	include Ruby3d

	def setup
	end

	def teardown
	end

	def test_initialize
		vector = Vector.new
		assert_equal 0, vector.x
		assert_equal 0, vector.y
		assert_equal 0, vector.z

		vector = Vector.new 1, 1, 1
		assert_equal 1, vector.x
		assert_equal 1, vector.y
		assert_equal 1, vector.z
	end

	def test_add
		v1 = Vector.new 1,1,1
		v2 = Vector.new 2,3,4

		got = v1 + v2

		assert_equal 3, got.x
		assert_equal 4, got.y
		assert_equal 5, got.z
	end

	def test_subtract
		v1 = Vector.new 1,1,1
		v2 = Vector.new 2,3,4

		got = v2 - v1

		assert_equal 1, got.x
		assert_equal 2, got.y
		assert_equal 3, got.z
	end

	def test_multiply
		vec = Vector.new 1,1,1

		got = vec * 10

		assert_equal 10, got.x
		assert_equal 10, got.y
		assert_equal 10, got.z
	end

	def test_divide
		vec = Vector.new 10,10,10

		got = vec / 2 

		assert_equal 5, got.x
		assert_equal 5, got.y
		assert_equal 5, got.z
	end

	def test_get_x
		vec = Vector.new 1, 2, 3

		assert_equal 1, vec.x
	end

	def test_get_y
		vec = Vector.new 1, 2, 3

		assert_equal 2, vec.y
	end

	def test_get_z
		vec = Vector.new 1, 2, 3

		assert_equal 3, vec.z
	end

	def test_set_x
		vec = Vector.new
		vec.x = 10

		assert_equal 10, vec.x
	end

	def test_set_y
		vec = Vector.new
		vec.y = 10

		assert_equal 10, vec.y
	end

	def test_set_z
		vec = Vector.new
		vec.z = 10

		assert_equal 10, vec.z
	end

	def test_dot
		v1 = Vector.new 1,0,1
		v2 = Vector.new 0,0,1

		got = v1.dot v2

		assert_equal 1.0, got
	end

	def test_cross
		v1 = Vector.new 1,0,0
		v2 = Vector.new 0,1,0

		got = v1.cross v2

		assert_equal 0, got.x
		assert_equal 0, got.y
		assert_equal 1, got.z
	end

	def test_length
		vec = Vector.new 1,0,0
		got = vec.length

		assert_equal 1, got

		vec = Vector.new 3, 4, 0
		got = vec.length

		assert_equal 5, got
	end

	def test_normalize
		vec = Vector.new 5,0,0
		got = vec.normalize

		assert_equal 1, got.x
		assert_equal 0, got.y
		assert_equal 0, got.z
	end

	def test_normalize_self
		vec = Vector.new 10,0,0
		vec.normalize!

		assert_equal 1, vec.x
		assert_equal 0, vec.y
		assert_equal 0, vec.z
	end

	def test_equal
		v1 = Vector.new 3,3,3
		v2 = Vector.new 3,3,3

		assert(v1.equal?(v2))

		v3 = Vector.new 1,1,1

		assert(!v1.equal?(v3))
	end
end
