require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
$: << File.dirname(__FILE__)

require 'entity_builder'

describe EntityBuilder do

  describe "test entity builder with only Foo defined" do
    before :each do

      @res_man = mock "res_man"
      @res_man.should_receive(:load_gameplay_config).with('entity_defs').and_return({:foo=>{:components=>[:fake_tester],:health=>73}})
      @entity_builder = EntityBuilder.new :resource_manager => @res_man
    end

    it "should define the class constant" do
      Foo.to_s.should == "Foo"
    end

    it "should set default values to instances" do
      @foo = Foo.new 1, {:entity_type=>:foo}
      @foo.health.should == 73
      @foo.health = 12
      @foo.health.should == 12
    end

    it "should set default values for classes" do
      Foo.default_health.should == 73
    end

    it "should mixin the components" do
      Foo.instance_methods.include?('fake_method').should == true
    end

  end

end
