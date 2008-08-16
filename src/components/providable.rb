# can provide a resource of some kind when asked
module Providable

  attr_accessor :resource, :resource_amount

  def self.included(target)
    target.add_setup_listener :setup_providable
    #target.can_fire :emtpy
  end

  def setup_providable(args)
    #require_components :audible
    @resource = self.resource
    @resource_amount = self.resource_amount
  end

  def empty?()
    @resource_amount == 0
  end

  # retrieves amount of resource, returns the amount taken
  def take(amount)
    if amount <= @resource_amount
      @resource_amount -= amount
      return amount 
    else
      available = @resource_amount
      @resource_amount = 0
      return available
    end
  end


end
