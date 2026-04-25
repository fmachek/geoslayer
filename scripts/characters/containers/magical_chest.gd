class_name MagicalChest
extends Chest
## Represents a chest which, in addition to regular abilities dropped
## by regular chests, also drops magical abilities such as [Summon]
## and [Storm].


func generate_ability_drop_pool() -> void:
	super()
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/summon_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/storm_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/teleport_pickup.tscn", 100))
