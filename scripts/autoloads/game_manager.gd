extends Node

## This autoload handles the main things the game needs, for example
## switching between different menus and the game, pausing and more.

## Emitted when the [Main] node is fully ready.
signal loaded_main(main: Main)
## Emitted when the game is paused.
signal paused_game()
## Emitted when the game is resumed.
signal resumed_game()
## Emitted when the game is won.
signal won_game()

## [Main] node containing the in-game UI and world.
var main_node: Main
## The number of the world currently selected.
var selected_world_number: int
## [code]true[/code] if the game can be paused.
var can_pause_game: bool = false
## User XP last given.
var last_xp_gained: int = 0
## Last game level achieved.
var level_achieved: int

var bg_particles_scene: PackedScene = preload(
	"res://scenes/user_interface/background_particles.tscn"
)
var bg_particles: CPUParticles2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_add_particles_to_ui(get_tree().root.get_node("MainMenu"))


## Selects a new world and starts the game.
func select_world(world_number: int) -> void:
	selected_world_number = world_number
	start_game()


## Instantiates the [Main] scene and switches to it.
func start_game() -> void:
	resume_game()
	main_node = load("res://scenes/main.tscn").instantiate()
	main_node.ready.connect(_on_main_ready)
	get_tree().change_scene_to_node(main_node)


## Exits the game.
func exit_game() -> void:
	get_tree().quit()


## Emits [member loaded_main] when [member main_node] is ready
## and enables pausing.
func _on_main_ready() -> void:
	can_pause_game = true
	loaded_main.emit(main_node)


# Input handling from Godot Docs
# (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
## Handles ESC presses and pauses/resumes if the game can be paused/resumed.
func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if get_tree().paused:
				resume_game()
			else:
				pause_game()


#region menu switching
## Switches to the main menu scene.
func switch_to_menu() -> void:
	switch_to_ui_scene("res://scenes/user_interface/main_menu/main_menu.tscn")


## Switches to the world selection UI scene.
func switch_to_world_selection() -> void:
	switch_to_ui_scene("res://scenes/user_interface/world_selection/world_selection_ui.tscn")


## Switches to the win screen UI scene.
func switch_to_win_screen() -> void:
	switch_to_ui_scene("res://scenes/user_interface/win_screen/win_screen.tscn")


## Switches to the permanent progression UI.
func switch_to_progression() -> void:
	switch_to_ui_scene("res://scenes/user_interface/progression/progression_ui.tscn")


## Switches to the credits screen.
func switch_to_credits() -> void:
	switch_to_ui_scene("res://scenes/user_interface/credits/credits_ui.tscn")


## Switches to a scene at a given [param path]. This assumes
## the scene is a UI scene - it disables pausing.
func switch_to_ui_scene(path: String) -> void:
	resume_game()
	can_pause_game = false
	var new_node = load(path).instantiate()
	_add_particles_to_ui(new_node)
	get_tree().change_scene_to_node(new_node)
	main_node = null
#endregion


## Pauses the game if allowed.
func pause_game() -> void:
	if can_pause_game:
		get_tree().paused = true
		paused_game.emit()


## Resumes the game if allowed.
func resume_game() -> void:
	if can_pause_game:
		get_tree().paused = false
		resumed_game.emit()


# Disables pausing on player death.
func _on_player_died() -> void:
	can_pause_game = false


## Gives XP to the user and switches to the win screen.
func win_game() -> void:
	won_game.emit()
	var character: PlayerCharacter = PlayerManager.current_player
	var character_level: Level = character.level
	level_achieved = character_level.current_level
	var user_xp: int = level_achieved * 5
	UserManager.add_xp(user_xp)
	last_xp_gained = user_xp
	UserManager.add_world_completion(selected_world_number)
	switch_to_win_screen()


func _add_particles_to_ui(ui_node: Control) -> void:
	if not is_instance_valid(bg_particles):
		bg_particles = bg_particles_scene.instantiate()
		bg_particles.name = "BackgroundParticles"
		var bg_particle_pos := Vector2(576, 680)
		bg_particles.position = bg_particle_pos
	if is_instance_valid(bg_particles.get_parent()):
		bg_particles.call_deferred("reparent", ui_node)
	else:
		ui_node.call_deferred("add_child", bg_particles)
	ui_node.call_deferred("move_child", bg_particles, 1)
