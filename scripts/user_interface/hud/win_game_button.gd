class_name WinGameButton
extends Button
## Represents a button which shows up when [signal WorldManager.boss_died]
## is emitted and triggers [method GameManager.win_game] when pressed.


func _ready() -> void:
	WorldManager.boss_died.connect(show)
	pressed.connect(GameManager.win_game)
