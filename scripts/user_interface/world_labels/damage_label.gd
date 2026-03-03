class_name DamageLabel
extends Label

var tween: Tween

func play_tween() -> void:
	tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -10), 0.75)
	tween.parallel().tween_property(self, "modulate:a", 0, 0.75)
	tween.tween_callback(queue_free)

func load_damage(damage: int, pos: Vector2):
	text = str(damage)
	global_position = pos
