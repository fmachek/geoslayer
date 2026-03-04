class_name ExitButton
extends Button

# Connect the pressed signal to the GameManager, which exits the game.
func _ready() -> void:
	pressed.connect(GameManager.exit_game)
