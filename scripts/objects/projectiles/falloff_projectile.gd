class_name FalloffProjectile
extends Projectile
## Type of [Projectile] whose damage decreases every physics frame.

## Minimum damage the [Projectile] must deal.
var min_damage: int = 2
## Used when calculating damage reduction every physics frame.
var damage_reduction_multiplier: float = 30.0
var _damage_reduction_buildup: float = 0.0
var _dmg_threshold: int = 1


func _physics_process(delta: float) -> void:
	super(delta)
	_reduce_damage(delta)


func _reduce_damage(delta: float) -> void:
	_damage_reduction_buildup += delta * damage_reduction_multiplier
	if _damage_reduction_buildup >= _dmg_threshold:
		if projectile_properties.damage - _dmg_threshold > min_damage:
			_damage_reduction_buildup -= _dmg_threshold
			projectile_properties.damage -= _dmg_threshold
