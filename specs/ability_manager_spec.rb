require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'constructor'
require 'resource_manager'
require 'ability_manager'

describe AbilityManager do

  describe "ability manager should manage what selections are able to do" do
    before :each do
      man = ResourceManager.new
      @ability_man = AbilityManager.new :resource_manager => man
    end

    it "should return [] for emtpy selections" do
      @ability_man.setup

      sel = EntitySelection.new
      @ability_man.abilities_for(sel).should == []
    end

    it "should return [] for emtpy selections" do
      @ability_man.setup

      # need mock selection
      sel = MockSelection.new 
      # w/ mock entities
      @ability_man.abilities_for(sel).should == [:sledgehammer]
    end

  end

end
