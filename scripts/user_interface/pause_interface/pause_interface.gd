class_name PauseInterface
extends Control
## Represents an UI overlay which shows up when the game is paused.

## Emitted when shown through [method _on_paused_game].
signal showed()


func _ready() -> void:
	GameManager.paused_game.connect(_on_paused_game)
	GameManager.resumed_game.connect(_on_resumed_game)
	%ResumeButton.pressed.connect(GameManager.resume_game)
	%WorldSelectionButton.pressed.connect(GameManager.switch_to_world_selection)
	%MainMenuButton.pressed.connect(GameManager.switch_to_menu)
	%RestartButton.pressed.connect(GameManager.start_game)
	%ExitButton.pressed.connect(GameManager.exit_game)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_paused_game():
	show()
	showed.emit()


func _on_resumed_game():
	hide()
