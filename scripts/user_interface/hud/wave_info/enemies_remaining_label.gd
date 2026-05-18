class_name EnemiesRemainingLabel
extends Label


func _ready() -> void:
	hide()
	WorldManager.enemies_remaining_changed.connect(_update_text)


func _update_text(enemies_remaining: int) -> void:
	if enemies_remaining == 0:
		hide()
	else:
		text = "Enemies remaining: %d" % enemies_remaining
		show()
