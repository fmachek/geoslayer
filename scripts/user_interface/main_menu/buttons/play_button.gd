class_name PlayButton
extends Button

# Connect the pressed signal to the GameManager, which starts the game.
func _ready() -> void:
	pressed.connect(GameManager.switch_to_world_selection)
