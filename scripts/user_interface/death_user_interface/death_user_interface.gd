class_name DeathUserInterface
extends Control

func _ready() -> void:
	PlayerManager.player_died.connect(_on_player_died)
	%RestartButton.pressed.connect(GameManager.start_game)
	%BackToMenuButton.pressed.connect(GameManager.switch_to_menu)

func _on_player_died(player: PlayerCharacter) -> void:
	show()
