extends Node

var current_world: World
var world_1_scene_path = "res://scenes/worlds/world_1.tscn"

# Temporary logic for testing
func _ready() -> void:
	load_world()

func _process(delta: float) -> void:
	pass

func load_world():
	current_world = load(world_1_scene_path).instantiate()
	$"/root/Main".add_child(current_world)
