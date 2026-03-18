extends Node

## This autoload handles world loading and emits signals such
## as wave_started so that nodes in the scene tree can easily
## connect to them and detect important events.

## Emitted when a new wave starts in the world.
signal wave_started()
## Emitted when a wave ends in the world.
signal wave_ended()
## Emitted when the time until the current wave ends in the world changes.
signal time_until_wave_end_changed(time: int)

## The [World] currently loaded.
var current_world: World
## Path to the [World] scene, where '%d' must be replaced with an integer.
var _world_path: String = "res://scenes/worlds/world_%d.tscn"


## Connects to [member GameManager.loaded_main] to ensure that
## the world is loaded only when [Main] is ready.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.loaded_main.connect(_on_game_manager_loaded_main)


## Loads the given world and adds it as a child of [param main].
## Also connectsthe wave manager's signals.
func load_world(main: Main, world_number: int) -> void:
	var world_scene_path: String = _world_path % world_number
	var world_scene: PackedScene = load(world_scene_path)
	if world_scene:
		current_world = world_scene.instantiate()
		main.add_child(current_world)
		current_world.wave_manager.wave_started.connect(
				func(): wave_started.emit())
		current_world.wave_manager.wave_ended.connect(
				func(): wave_ended.emit())
		current_world.wave_manager.time_until_wave_end_changed.connect(
			func(time: int): time_until_wave_end_changed.emit(time))


## Loads a world in [param main] when it is ready.
func _on_game_manager_loaded_main(main: Main) -> void:
	load_world(main, GameManager.selected_world_number)


# Starts a new wave when the button for it is pressed.
func _on_spawn_wave_button_pressed() -> void:
	current_world.start_wave()
