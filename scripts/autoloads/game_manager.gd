## This autoload handles the main things the game needs: switching between
## the menus and the game, game pausing and world selection.
extends Node

## Main Node2D containing the in-game UI and world.
var main_node: Main
## The number of the world currently selected.
var selected_world_number: int

## Emitted when the Main node is fully ready.
signal loaded_main(main: Main)
## Emitted when the game is paused.
signal paused_game()
## Emitted when the game is resumed.
signal resumed_game()

## Says if the game can be paused or not. False if the player is dead for example.
var can_pause_game: bool = false

## Sets the process mode to ALWAYS when entering the scene tree.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Selects a new world and starts the game.
func select_world(world_number: int) -> void:
	selected_world_number = world_number
	start_game()

## Instantiates the Main scene and switches to it.
func start_game() -> void:
	resume_game()
	main_node = load("res://scenes/main.tscn").instantiate()
	main_node.ready.connect(_on_main_ready)
	get_tree().change_scene_to_node(main_node)

## Exits the game.
func exit_game() -> void:
	get_tree().quit()

## Emits the loaded_main signal when Main is ready and enables pausing.
func _on_main_ready() -> void:
	can_pause_game = true
	loaded_main.emit(main_node)

## Listens for ESC pressed and pauses/resumes if the game can be paused/resumed.
# Input handling from Godot Docs
# (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
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
