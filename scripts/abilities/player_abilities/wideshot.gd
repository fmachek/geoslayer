class_name Wideshot
extends Ability
## Represents the Wideshot ability which fires projectiles in a wide cone.
## It is most effective at close range and applies a long knockback.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile]s fired when cast.
var projectile_speed: int = 5
## Base damage of the [Projectile]s fired when cast.
var base_damage: int = 10
## Radius of the [Projectile]s fired when cast.
var projectile_radius: int = 6
## Knockback applied to [Character]s hit by the [Projectile]s.
var projectile_knockback: float = 400.0

## Amount of [Projectile]s fired on cast.
var projectile_amount: int = 5
## Angle of the cone spread in radians.
var spread_angle: float = deg_to_rad(40)


func _init() -> void:
	super(1, "Shoots projectiles in a cone.")


func _perform_ability() -> void:
	var projectiles := ProjectileFunctions.fire_projectile_cone(
			_PROJ_SCENE, projectile_amount, spread_angle,
			character, base_damage, projectile_speed, projectile_radius)
	for proj in projectiles:
		proj.knockback = projectile_knockback
	finished_casting.emit()
