class_name Drop
extends Node2D

var item_scene_path: String
var chance: float

func _init(item_scene_path: String, chance: float):
	self.item_scene_path = item_scene_path
	self.chance = chance
