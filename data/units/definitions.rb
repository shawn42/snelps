
define_unit :earth_worker do
  race :earth
  attack_power 20
  health 55
end

define_unit :earth_warrior do
  inherit_from :earth_worker
  attack_power 30
  speed 6
  behavior :audible
end

define_unit :fire_worker do
  race :fire
  attack_power 25
  health 50
end
