create_entity nil, :palm, 12, 2
create_entity nil, :palm, 8, 3
create_entity nil, :palm, 4, 3
create_entity nil, :palm, 10, 5

create_entity nil, :animal, 24, 25
create_entity nil, :animal, 14, 25
create_entity nil, :animal, 28, 5

create_entity :local, :fire_explorer, 4, 4
create_entity :local, :fire_explorer, 22, 22
create_entity :local, :fire_explorer, 22, 23
create_entity :local, :fire_explorer, 23, 22
create_entity :local, :fire_explorer, 23, 23
create_entity :local, :fire_explorer, 23, 24

create_entity nil, :vim, 1, 1

create_entity :local, :well_spring, 5, 11
create_entity :local, :big_base, 10, 11
create_entity :local, :earth_worker, 12, 11
create_entity :local, :earth_worker, 14, 11

create_entity nil, :portal, 59, 59

create_entity :local, :fire_worker, 1, 2
create_entity :local, :fire_worker, 1, 3
create_entity :local, :fire_worker, 2, 3
create_entity :local, :fire_worker, 2, 2

on :occupancy_change do |type,ent,x,y|
  fire :victory if x == 59 and y == 59 and ent.player_id == local_player.server_id
end

on :tick do |tick_time, total_time|
  # 30 seconds to find the goal
  fire :defeat if total_time > 300000
end

