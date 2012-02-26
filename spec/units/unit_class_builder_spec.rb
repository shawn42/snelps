require 'spec_helper'

describe UnitClassBuilder do
  inject_mocks :resource_manager

  describe "#build" do

    before do
      Object.send(:remove_const, :Worker) if defined? Worker
      Object.send(:remove_const, :Warrior) if defined? Warrior
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
        w = build_worker
        w.should respond_to(:health)
        w.health.should == 55
        w.attack_power.should == 20
      end

      it 'builds a class that has attr that work' do
        build
        w = build_worker
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
        war = build_warrior
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
      it 'raises on unknown parent' do
        # TODO make this work in any order?
        lambda { build }.should raise_exception(/not yet defined/)
      end
    end

    context 'with behaviors' do
      let(:definition) { 
        """
          define_unit :worker do
            health 55
            attack_power 20
            behavior :audible
          end

          define_unit :warrior do
            inherit_from :worker
            attack_power 50
          end
        """ }

      it 'builds in behaviors correctly' do
        build
        w = build_worker
        w.is?(:audible).should be_true
      end
    end

    context 'passing in attributes hash' do
      let(:definition) { 
        """
          define_unit :worker do
            attributes health: 55, attack_power: 21 
            health 56
          end
        """ }

      it 'uses attributes' do
        build
        w = build_worker
        w.attack_power.should == 21
      end

      it 'can override attrs set with attributes' do
        build
        w = build_worker
        w.health.should == 56
      end
    end


    private
    def build
      subject.build 'units/definitions.rb'
    end

    let(:sound_manager) { stub 'sound manager' }
    let(:stage) { stub 'stage', sound_manager: sound_manager }
    def build_worker
      Worker.new stage: stage
    end

    def build_warrior
      Warrior.new stage: stage
    end
  end
end
