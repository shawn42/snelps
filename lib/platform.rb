# Helper functions for determining platform

class Platform
	def self.mac?
	  return PLATFORM =~ /darwin/
	end
	
	def self.windows?
	  return PLATFORM =~ /mswin/
	end
	
	def self.linux?
		PLATFORM =~ /linux/
	end
end
