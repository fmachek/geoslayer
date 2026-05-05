class_name Drop
extends Node2D
## Represents an item in a drop pool.
##
## Contains a path to a scene of the item the [Drop] represents.
## Also contains the drop chance.

## Path to the scene of the item the [Drop] represents.
var item_scene_path: String
## Chance of the item dropping.
var chance: float


## Sets [member item_scene_path] and [member chance].
func _init(scene_path: String, drop_chance: float):
	self.item_scene_path = scene_path
	self.chance = drop_chance
