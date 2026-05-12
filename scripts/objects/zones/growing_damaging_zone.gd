class_name GrowingDamagingZone
extends DamagingZone
## Represents a [DamagingZone] which starts with a radius of 0
## and grows over time.

## The final radius.
var final_radius: float
var _radius_tween: Tween


func _init() -> void:
	is_bound_to_caster = false
	should_emit_tick_particles = false


func _ready() -> void:
	super()
	final_radius = radius
	radius = 0.0
	_start_growing()


func _start_growing() -> void:
	if _radius_tween:
		_radius_tween.kill()
	_radius_tween = create_tween()
	_radius_tween.tween_property(self, "radius", final_radius, life_time)
	_radius_tween.play()
