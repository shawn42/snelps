# Helper functions for determining platform

class Platform
	def self.mac?
	  return true#PLATFORM =~ /darwin/
	end
	
	def self.windows?
	  return false#PLATFORM =~ /mswin/
	end
	
	def self.linux?
		return false#PLATFORM =~ /linux/
	end
end
