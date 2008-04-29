#
# :subscribe: public method for subscribing to events (aka 'subscribe', 'on', 'when')
# :fire: protected method for firing events (aka 'fire', 'emit', 'notify')
# Example:
#   class Car < Thinger
#     extend Publisher
#     can_fire :started, :crashing
#
#     def drink_n_drive
#       fire :crashing
#     end
#   end
#
#   Car.new.when :crashing do jump_out_window end 
#
module Publisher
	# Use this method (or one of the aliases) to declare which events you support
	# Once invoked, your class will have the neccessary supporting methods for subscribing and firing.
	def has_events(*args)
		include InstanceMethods unless @published_events
		@published_events ||= []
		@published_events << args
		@published_events.flatten!
	end
	alias :has_event :has_events
	alias :can_fire :has_events

	# Use this method to allow subscription and firing of arbitrary events.
	# This is convenient if, eg, your class has dynamic event names.
	# Don't use this unless you have to; it's better to declare your events if you 
	# can.  
	def has_any_event
		include InstanceMethods unless @published_events
		@published_events = :any_event_is_ok
	end
	alias :can_fire_anything :has_any_event
	
	# Container for the instance methods that will be mixed-in to extenders of Publisher.
	# These methods get mixed in when you use the 'has_events' call.
	module InstanceMethods
		# Sign up a code block to be executed when an event is fired.
		# It's important to know the signature of the event, as your proc needs 
		# to accept incoming parameters accordingly.
		def subscribe(event, &block)
		  ensure_valid event
			@subscriptions ||= {}
			listeners = @subscriptions[event]
			listeners ||= []
			listeners << block
			@subscriptions[event] = listeners
		end
		alias :when :subscribe
		alias :on :subscribe
    
    def unsubscribe(event, listener)
		  ensure_valid event
      if @subscriptions && @subscriptions[event]
        @subscriptions[event].delete_if do |block|
          eval('self',block.binding).equal?(listener)
        end
      end
    end

    def unsubscribe_all(event)
		  ensure_valid event
      if @subscriptions && @subscriptions[event]
        @subscriptions[event] = []
      end
    end

		protected
		# Fire an event with 0 or more outbound parameters
		def fire(event, *args)
			ensure_valid event
			listeners = @subscriptions[event] if @subscriptions
			listeners.each do |l| l.call(*args) end if listeners
		end
		alias :emit :fire
		alias :notify :fire

		# Does nothing if the current class supports the named event.
		# Raises RuntimeError otherwise.
		def ensure_valid(event)
			events = self.class.class_eval { @published_events }
			return if events == :any_event_is_ok
			raise "Event '#{event}' not available" unless events and events.include?(event)
		end
	end
end
