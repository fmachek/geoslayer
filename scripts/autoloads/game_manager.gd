extends Node

## This autoload handles the main things the game needs: switching between
## the menus and the game, game pausing and world selection.

## Emitted when the Main node is fully ready.
signal loaded_main(main: Main)
## Emitted when the game is paused.
signal paused_game()
## Emitted when the game is resumed.
signal resumed_game()
## Emitted when the game is won.
signal won_game()

## Main [Node2D] containing the in-game UI and world.
var main_node: Main
## The number of the world currently selected.
var selected_world_number: int
## [code]true[/code] if the game can be paused.
var can_pause_game: bool = false
## User XP last given.
var last_xp_gained: int = 0
## Last game level achieved.
var level_achieved: int


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


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


## Emits [member GameManager.loaded_main when 
## [member GameManager.main_node] is ready and enables pausing.
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


## Switches to the main menu scene.
func switch_to_menu() -> void:
	resume_game()
	can_pause_game = false
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu/main_menu.tscn")
	main_node = null


## Switches to the world selection UI scene.
func switch_to_world_selection() -> void:
	resume_game()
	can_pause_game = false
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu/world_selection_ui.tscn")
	main_node = null


## Switches to the win screen UI scene.
func switch_to_win_screen() -> void:
	resume_game()
	can_pause_game = false
	get_tree().change_scene_to_file("res://scenes/user_interface/win_screen/win_screen.tscn")
	main_node = null


## Switches to the permanent progression UI.
func switch_to_progression() -> void:
	resume_game()
	can_pause_game = false
	get_tree().change_scene_to_file("res://scenes/user_interface/progression/progression_ui.tscn")
	main_node = null


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
	switch_to_win_screen()
