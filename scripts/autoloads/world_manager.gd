extends Node

var current_world: World # Current world loaded
var world_1_scene_path = "res://scenes/worlds/world_1.tscn"
# Note: this world loading is temporary and will be replaced with a better system

func _ready() -> void:
	GameManager.loaded_main.connect(_on_game_manager_loaded_main)

# Loads the world and adds it as a child of the Main node.
func load_world(main: Main):
	current_world = load(world_1_scene_path).instantiate()
	main.add_child(current_world)

# Loads a world in the Main node when the Main node is ready.
func _on_game_manager_loaded_main(main: Main) -> void:
	load_world(main)
