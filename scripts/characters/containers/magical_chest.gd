class_name MagicalChest
extends Chest
## Represents a chest which, in addition to regular abilities dropped
## by regular chests, also drops magical abilities such as [Summon]
## and [Storm].


func generate_ability_drop_pool() -> void:
	super()
	var magical_ability_names: Array[String] = [
		"summon", "storm", "teleport"
	]
	add_abilities_to_drop_pool(magical_ability_names)
