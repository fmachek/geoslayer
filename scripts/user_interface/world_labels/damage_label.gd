class_name DamageLabel
extends Label
## Represents a label displaying the amount of damage dealt.

var _tween: Tween


## Plays a fade out and move effect, then calls [method queue_free].
func play_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "global_position", global_position + Vector2(0, -10), 0.75)
	_tween.parallel().tween_property(self, "modulate:a", 0, 0.75)
	_tween.tween_callback(queue_free)


## Sets the label's text to match [param damage] and
## moves to [param pos].
func load_damage(damage: int, pos: Vector2):
	text = str(damage)
	global_position = pos
