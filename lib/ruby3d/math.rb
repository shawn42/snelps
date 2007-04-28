##
## Supplementary file for the Ruby3d library. This file defines a few useful
## "constants." I do it this way because Ruby handles Constants the wrong way, 
## I believe. Where I to define constants as actual constants, then you'd get this:
##
## val = Rotation::IDENTITY
## val.x = 10
##
## val2 = Rotation::IDENTITY
## puts val2.x => '10'
##
## We do NOT want this, for sure.
##
## This file should be all you need for your math needs, as it also includes
## Ruby's own math library, 'complex', and adds the 3D constructs to its module
##

## Do some config checking as we are loading a binary
require 'rbconfig'

case RUBY_PLATFORM
when /mswin32/
	require 'ruby3d.dll'
else
	require 'ruby3d.so'
end

require 'complex'

module Math
	include Ruby3d

  PI = 3.14159265358979323846

	def Vector.ZERO
		Vector.new(0,0,0)
	end

	def Vector.X_AXIS
		Vector.new(1,0,0)
	end

	def Vector.Y_AXIS
		Vector.new(0,1,0)
	end

	def Vector.Z_AXIS
		Vector.new(0,0,1)
	end

	def Vector.UNIT_SCALE
		Vector.new(1,1,1)
	end

	def Matrix4.ZERO
		Matrix4.new([	0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0 ])
	end

	def Matrix4.IDENTITY
		Matrix4.new([	1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 ])
	end

	def Rotation.IDENTITY
		Rotation.new(Vector.new(0,0,0), 1)
	end

end
