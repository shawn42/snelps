require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'map'

describe Map do

  describe "non empty 4x4 tiled, 32px tiles map" do
    before :each do
      @map = Map.new
      @map.width = 4
      @map.height = 4
      @map.tile_size = 32
      @map.half_tile_size = 16
    end

    it "should covert up/left coords to tiles correctly" do
      exp = [0,0]
      @map.coords_to_tiles(12, 12).should == exp
      @map.coords_to_tiles(0, 0).should == exp
      @map.coords_to_tiles(15, 15).should == exp
    end

    it "should covert bottom/left coords to tiles correctly" do
      exp = [0,3]
      @map.coords_to_tiles(12, 122).should == exp
      @map.coords_to_tiles(0, 97).should == exp
      @map.coords_to_tiles(31, 127).should == exp
    end

    it "should covert bottom/right coords to tiles correctly" do
      exp = [3,3]
      @map.coords_to_tiles(122, 122).should == exp
      @map.coords_to_tiles(97, 97).should == exp
      @map.coords_to_tiles(127, 127).should == exp
    end

    it "should covert up/right coords to tiles correctly" do
      exp = [3,0]
      @map.coords_to_tiles(122, 12).should == exp
      @map.coords_to_tiles(97, 0).should == exp
      @map.coords_to_tiles(127, 31).should == exp
    end

    it "should convert up/left tiles to coords correctly" do
      @map.tiles_to_coords(0, 0).should == [16,16]
    end

    it "should convert up/right tiles to coords correctly" do
      @map.tiles_to_coords(0, 3).should == [16,112]
    end

    it "should convert bottom/left tiles to coords correctly" do
      @map.tiles_to_coords(3, 0).should == [112,16]
    end

    it "should convert bottom/right tiles to coords correctly" do
      @map.tiles_to_coords(3, 3).should == [112,112]
    end

  end

end
