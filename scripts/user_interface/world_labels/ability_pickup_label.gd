class_name AbilityPickupLabel
extends Label

var fade_tween: Tween

func fade_out():
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, 1)
	fade_tween.tween_callback(queue_free)
