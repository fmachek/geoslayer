extends Node

var current_world: World # Current world loaded
var world_1_scene_path = "res://scenes/worlds/world_1.tscn"
# Note: this world loading is temporary and will be replaced with a better system

signal wave_started()
signal wave_ended()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.loaded_main.connect(_on_game_manager_loaded_main)

# Loads the world and adds it as a child of the Main node.
func load_world(main: Main):
	current_world = load(world_1_scene_path).instantiate()
	main.add_child(current_world)
	current_world.wave_manager.wave_started.connect(func(): wave_started.emit())
	current_world.wave_manager.wave_ended.connect(func(): wave_ended.emit())

# Loads a world in the Main node when the Main node is ready.
func _on_game_manager_loaded_main(main: Main) -> void:
	load_world(main)

func _on_spawn_wave_button_pressed() -> void:
	current_world.start_wave()
