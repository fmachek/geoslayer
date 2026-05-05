class_name DeathUserInterface
extends Control
## Represents a UI screen which appears when the player dies.
## The buttons don't do anything for a short period of time after
## it is shown to prevent accidental clicks.

@onready var _restart_button: Button = %RestartButton
@onready var _menu_button: Button = %BackToMenuButton
@onready var _enable_timer: Timer = $ClickEnableTimer


func _ready() -> void:
	PlayerManager.player_died.connect(_on_player_died.unbind(1))


func _on_player_died() -> void:
	show()
	_enable_timer.start()


func _on_click_enable_timer_timeout() -> void:
	_restart_button.pressed.connect(GameManager.start_game)
	_menu_button.pressed.connect(GameManager.switch_to_menu)
