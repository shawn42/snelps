# Helper functions for determining platform

# TODO how do I do this in ruby 1.9, since PLATFORM doesn't exist?
class Platform
	def self.mac?
	  return RUBY_PLATFORM =~ /darwin/
	end
	
	def self.windows?
	  return RUBY_PLATFORM =~ /mswin/
	end
	
	def self.linux?
		return RUBY_PLATFORM =~ /linux/
	end
end
