extends Node

var main_node: Main # Main 2D node which is going to contain the world etc
var selected_world_number: int
signal loaded_main(main: Main) # Emitted when the Main node is fully ready
signal paused_game()
signal resumed_game()

var can_pause_game: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func select_world(world_number: int) -> void:
	selected_world_number = world_number
	start_game()

# Switches to the Main scene, where the world will be loaded.
func start_game() -> void:
	main_node = load("res://scenes/main.tscn").instantiate()
	main_node.ready.connect(_on_main_ready)
	get_tree().change_scene_to_node(main_node)

func exit_game() -> void:
	get_tree().quit()

# Emits the loaded_main signal when Main is ready so that
# other nodes such as WorldManager can react to it.
func _on_main_ready() -> void:
	can_pause_game = true
	loaded_main.emit(main_node)

# Input handling from Godot Docs (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if get_tree().paused:
				resume_game()
			else:
				pause_game()

func switch_to_menu() -> void:
	resume_game()
	can_pause_game = false
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu/main_menu.tscn")
	main_node = null

func switch_to_world_selection() -> void:
	resume_game()
	can_pause_game = false
	get_tree().change_scene_to_file("res://scenes/user_interface/main_menu/world_selection_ui.tscn")
	main_node = null

func pause_game():
	if can_pause_game:
		get_tree().paused = true
		paused_game.emit()

func resume_game():
	if can_pause_game:
		get_tree().paused = false
		resumed_game.emit()

func _on_player_died():
	can_pause_game = false
