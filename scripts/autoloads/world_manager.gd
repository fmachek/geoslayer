extends Node

var current_world: World # Current world loaded
var world_path = "res://scenes/worlds/world_%d.tscn" # World path template

signal wave_started()
signal wave_ended()
signal time_until_wave_end_changed(time: int)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.loaded_main.connect(_on_game_manager_loaded_main)

# Loads the world and adds it as a child of the Main node.
func load_world(main: Main, world_number: int):
	current_world = load(world_path % world_number).instantiate()
	main.add_child(current_world)
	current_world.wave_manager.wave_started.connect(func(): wave_started.emit())
	current_world.wave_manager.wave_ended.connect(func(): wave_ended.emit())
	current_world.wave_manager.time_until_wave_end_changed.connect(func(time: int): time_until_wave_end_changed.emit(time))

# Loads a world in the Main node when the Main node is ready.
func _on_game_manager_loaded_main(main: Main) -> void:
	load_world(main, GameManager.selected_world_number)

func _on_spawn_wave_button_pressed() -> void:
	current_world.start_wave()
