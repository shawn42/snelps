create_entity nil, :tree, 4, 3
create_entity nil, :tree, 5, 3
create_entity nil, :tree, 6, 3
create_entity nil, :tree, 7, 3
create_entity nil, :tree, 8, 3
create_entity nil, :tree, 9, 3
create_entity nil, :tree, 10, 3
create_entity nil, :tree, 11, 3
create_entity nil, :tree, 12, 3
create_entity nil, :tree, 13, 3
create_entity nil, :tree, 14, 3
create_entity nil, :tree, 4, 4
create_entity nil, :tree, 5, 4
create_entity nil, :tree, 6, 4
create_entity nil, :tree, 7, 4
create_entity nil, :tree, 8, 4
create_entity nil, :tree, 9, 4
create_entity nil, :tree, 10, 4
create_entity nil, :tree, 11, 4
create_entity nil, :tree, 12, 4
create_entity nil, :tree, 13, 4
create_entity nil, :tree, 14, 4
create_entity nil, :tree, 4, 5
create_entity nil, :tree, 5, 5
create_entity nil, :tree, 6, 5
create_entity nil, :tree, 7, 5
create_entity nil, :tree, 8, 5
create_entity nil, :tree, 9, 5
create_entity nil, :tree, 10, 5
create_entity nil, :tree, 11, 5
create_entity nil, :tree, 12, 5
create_entity nil, :tree, 13, 5
create_entity nil, :tree, 14, 5

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
  fire :defeat if total_time > 30000
end

