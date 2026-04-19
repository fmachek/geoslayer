class_name AbilityPickupLabel
extends Label
## Represents a label used to display the name of the
## [Ability] unlocked by an [AbilityPickup].

var _fade_tween: Tween


## Fades out and then calls [method queue_free].
func fade_out():
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0, 1)
	_fade_tween.tween_callback(queue_free)
