require File.dirname(__FILE__) + '/../test_helper'
require 'map'

class MapTest < Test::Unit::TestCase

  def setup
    @map = Map.new
    @map.width = 4
    @map.height = 4
    @map.tile_size = 32
    @map.half_tile_size = 16
  end

  def test_coords_to_tiles_up_left
    exp = [0,0]
    assert_equal exp, @map.coords_to_tiles(12, 12)
    assert_equal exp, @map.coords_to_tiles(0, 0)
    assert_equal exp, @map.coords_to_tiles(15, 15)
  end

  def test_coords_to_tiles_bottom_left
    exp = [0,3]
    assert_equal exp, @map.coords_to_tiles(12, 122)
    assert_equal exp, @map.coords_to_tiles(0, 97)
    assert_equal exp, @map.coords_to_tiles(31, 127)
  end

  def test_coords_to_tiles_bottom_right
    exp = [3,3]
    assert_equal exp, @map.coords_to_tiles(122, 122)
    assert_equal exp, @map.coords_to_tiles(97, 97)
    assert_equal exp, @map.coords_to_tiles(127, 127)
  end

  def test_coords_to_tiles_up_right
    exp = [3,0]
    assert_equal exp, @map.coords_to_tiles(122, 12)
    assert_equal exp, @map.coords_to_tiles(97, 0)
    assert_equal exp, @map.coords_to_tiles(127, 31)
  end

  def test_tiles_to_coords_up_left
    exp = [16,16]
    assert_equal exp, @map.tiles_to_coords(0, 0)
  end

  def test_tiles_to_coords_up_right
    exp = [16,112]
    assert_equal exp, @map.tiles_to_coords(0, 3)
  end

  def test_tiles_to_coords_bottom_left
    exp = [112,16]
    assert_equal exp, @map.tiles_to_coords(3, 0)
  end

  def test_tiles_to_coords_bottom_right
    exp = [112,112]
    assert_equal exp, @map.tiles_to_coords(3, 3)
  end

end
