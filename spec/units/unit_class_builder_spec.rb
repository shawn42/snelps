require 'spec_helper'

describe UnitClassBuilder do
  inject_mocks :resource_manager

  describe "#build" do
    before do
      Object.send(:remove_const, :Worker) if defined? Worker
      defined?(Worker).should be_false
      @resource_manager.stubs(:load_data_file).
        with('units/definitions.rb').returns definition
    end

    context 'single basic unit definition' do
      let(:definition) { 
        """
          define_unit :worker do
            health 55
            attack_power 20
          end
        """ }

      it 'builds a basic class' do
        build
        defined?(Worker).should be_true
        Worker.ancestors[1].should == Actor
      end

      it 'builds a class with default attributes' do
        build
        w = Worker.new
        w.should respond_to(:health)
        w.health.should == 55
        w.attack_power.should == 20
      end

      it 'builds a class that has attr that work' do
        build
        w = Worker.new
        w.health.should == 55
        w.health = 99
        w.health.should == 99
      end

    end

    context 'extended unit definitions' do
      let(:definition) { 
        """
          define_unit :worker do
            health 55
            attack_power 20
          end

          define_unit :warrior do
            inherit_from :worker
            attack_power 50
          end
        """ }

      it 'builds a class that inherits defaults from parent class' do
        build
        defined?(Warrior).should be_true
        war = Warrior.new
        war.health.should == 55
        war.attack_power.should == 50
      end

    end

    context 'definitions out of order' do
      let(:definition) { 
        """
          define_unit :warrior do
            inherit_from :worker
            attack_power 50
          end

          define_unit :worker do
            health 55
            attack_power 20
          end
        """ }
      # TODO make this work in any order?
      it 'raises on unknown parent' do
        lambda { build }.should raise_exception(/not yet defined/)
      end
    end


    private
    def build
      subject.build 'units/definitions.rb'
    end
  end
end
