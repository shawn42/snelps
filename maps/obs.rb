create_entity :tree, nil, 4, 3
create_entity :tree, nil, 5, 3
create_entity :tree, nil, 6, 3
create_entity :tree, nil, 7, 3
create_entity :tree, nil, 8, 3
create_entity :tree, nil, 9, 3
create_entity :tree, nil, 10, 3
create_entity :tree, nil, 11, 3
create_entity :tree, nil, 12, 3
create_entity :tree, nil, 13, 3
create_entity :tree, nil, 14, 3
create_entity :tree, nil, 4, 4
create_entity :tree, nil, 5, 4
create_entity :tree, nil, 6, 4
create_entity :tree, nil, 7, 4
create_entity :tree, nil, 8, 4
create_entity :tree, nil, 9, 4
create_entity :tree, nil, 10, 4
create_entity :tree, nil, 11, 4
create_entity :tree, nil, 12, 4
create_entity :tree, nil, 13, 4
create_entity :tree, nil, 14, 4
create_entity :tree, nil, 4, 5
create_entity :tree, nil, 5, 5
create_entity :tree, nil, 6, 5
create_entity :tree, nil, 7, 5
create_entity :tree, nil, 8, 5
create_entity :tree, nil, 9, 5
create_entity :tree, nil, 10, 5
create_entity :tree, nil, 11, 5
create_entity :tree, nil, 12, 5
create_entity :tree, nil, 13, 5
create_entity :tree, nil, 14, 5

create_entity :animal, nil, 24, 25
create_entity :animal, nil, 14, 25
create_entity :animal, nil, 28, 5

create_entity :bird, 1, 2, 2
create_entity :bird, 1, 22, 22
create_entity :bird, 1, 22, 23
create_entity :bird, 1, 23, 22
create_entity :bird, 1, 23, 23
create_entity :bird, 1, 23, 24

create_entity :vim, nil, 1, 1


create_entity :portal, nil, 59, 59

create_entity :worker, 1, 1, 2

add_trigger do
  occs = get_occupants_at 59, 59, 1, 1, 1
  unless occs.empty?
    fire :victory
  end
end


