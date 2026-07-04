class_name PickupLabel
extends Label

var _fade_tween: Tween


func fade_out():
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0, 1.0)
	_fade_tween.tween_callback(queue_free)
