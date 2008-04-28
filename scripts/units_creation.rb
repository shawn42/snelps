require 'yaml'

h = {}

w = {}
w[:components] = [:positionable, :pathfollowable, :animatable, :drawable]
w[:health] = 100
w[:armor] = 0
w[:range] = 5
w[:attack_power] = 10
w[:speed] = 30
w[:images] = {}
w[:images][:walking] = ["worker_walking", 0..8]
w[:images][:building] = ["worker_building", 0..16]

h[:worker] = w

e = {}
e[:components] = [:positionable, :pathfollowable, :animatable, :drawable]
e[:health] = 80
e[:armor] = 0
e[:range] = 10
e[:attack_power] = 5
e[:speed] = 30
e[:images] = {}
e[:images][:walking] = ["worker_walking", 0..8]
e[:images][:engineering] = ["worker_engineering", 0..8]

h[:engineer] = e



File.open ARGV[0], 'w' do |f|
  f.write h.to_yaml
end
