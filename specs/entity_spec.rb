require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'entity'

describe Entity do

  describe "generic entity (no definition)" do
    before :each do
      @server_id = 1973
      @ent_type = :generic
      @entity = Entity.new @server_id, {:entity_type=>@ent_type}
    end

    after :each do
      Entity.instance_variable_set("@update_listeners",[])
      Entity.instance_variable_set("@setup_listeners",[])
    end

    it "should set itself up correctly" do
      @entity.server_id.should == @server_id
      @entity.entity_type.should == @ent_type
    end

    it "should call all setup listeners" do
      fake_arg = 1983

      Entity.add_setup_listener :fake_setup
      Entity.add_setup_listener :fake_setup_two

      @entity.should_receive(:fake_setup).with(fake_arg)
      @entity.should_receive(:fake_setup_two).with(fake_arg)

      @entity.setup fake_arg
    end

    it "should call all update listeners" do
      update_time = 1983

      Entity.add_update_listener :fake_method
      Entity.add_update_listener :fake_method_two
      @entity.should_receive(:fake_method).with(update_time)
      @entity.should_receive(:fake_method_two).with(update_time)

      @entity.update update_time
    end

  end

end
