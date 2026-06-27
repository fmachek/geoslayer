class_name WinGameButton
extends GlowingButton


func _ready() -> void:
	super()
	WorldManager.boss_died.connect(show)
	pressed.connect(GameManager.win_game)
