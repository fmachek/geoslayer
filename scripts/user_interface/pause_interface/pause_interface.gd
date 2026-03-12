class_name PauseInterface
extends Control

func _ready() -> void:
	GameManager.paused_game.connect(_on_paused_game)
	GameManager.resumed_game.connect(_on_resumed_game)
	%ResumeButton.pressed.connect(GameManager.resume_game)
	%WorldSelectionButton.pressed.connect(GameManager.switch_to_world_selection)
	%MainMenuButton.pressed.connect(GameManager.switch_to_menu)
	%ExitButton.pressed.connect(GameManager.exit_game)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_paused_game():
	show()

func _on_resumed_game():
	hide()
