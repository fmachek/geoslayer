class_name Boss1
extends Boss
## Represents the first [Boss].
##
## In the first phase, this [Boss] uses [Cannonball] and a
## modified version of [Storm] (its variables are changed).
##
## In the second phase, the [Stations] and [Orbit] abilities
## are added to its kit.
##
## Finally, in the third phase, the [Reinforcements] [Ability]
## is added to its kit.[br][br]
##
## The [Stations], [Orbit] and [Reinforcements] abilities were made
## specifically for this [Boss], meaning that they cannot be unlocked
## by the player nor are they used by other characters.


func generate_drop_pool() -> void:
	drop_pool.append(Drop.new(
			"res://scenes/objects/stat_point_drops/stat_point_drop.tscn", 100))
	drop_pool.append(Drop.new(
			"res://scenes/objects/stat_point_drops/stat_point_drop.tscn", 25))


func _load_abilities() -> void:
	var storm := Storm.new()
	storm.zone_radius = 350
	storm.cast_time = 2.0
	storm.cooldown = 18.0
	_load_ability(storm)
	_load_ability(Cannonball.new())


func _start_phase_1() -> void:
	pass


func _start_phase_2() -> void:
	_load_ability(Stations.new())
	_load_ability(Orbit.new())
	pass


func _start_phase_3() -> void:
	_load_ability(Reinforcements.new())
