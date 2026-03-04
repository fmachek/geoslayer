extends Node

var main_node: Main # Main 2D node which is going to contain the world etc
signal loaded_main(main: Main) # Emitted when the Main node is fully ready

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
	loaded_main.emit(main_node)
