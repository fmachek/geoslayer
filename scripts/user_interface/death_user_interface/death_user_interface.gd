class_name DeathUserInterface
extends Control
## Represents a UI screen which appears when the player dies.

@onready var _restart_button: Button = %RestartButton
@onready var _menu_button: Button = %BackToMenuButton


func _ready() -> void:
	PlayerManager.player_died.connect(_on_player_died)
	_restart_button.pressed.connect(GameManager.start_game)
	_menu_button.pressed.connect(GameManager.switch_to_menu)


func _on_player_died(player: PlayerCharacter) -> void:
	show()
