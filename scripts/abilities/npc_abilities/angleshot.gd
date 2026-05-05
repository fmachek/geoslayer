class_name Angleshot
extends Ability
## Represents the Angleshot ability which fires two projectiles
## in different directions. Both of the directions are the direction to
## [member character.target_pos] offset by [member angle] to the left and right.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Speed of the [Projectile]s fired on cast.
var projectile_speed: int = 2
## Base damage of the [Projectile]s fired on cast.
var base_damage: int = 15
## Radius of the [Projectile]s fired on cast.
var projectile_radius: int = 8
## Angle in degrees by which the direction to [member character.target_pos]
## is offset to get the [Projectile] angle.
var angle: float = 45.0


func _init() -> void:
	super(0.5, "Fires two projectiles in different directions.")


func _perform_ability() -> void:
	var dir_to_target: Vector2 = character.global_position.direction_to(character.target_pos)
	var angle_to_target: float = dir_to_target.angle()
	_fire_projectile_at_angle(angle_to_target + deg_to_rad(-angle))
	_fire_projectile_at_angle(angle_to_target + deg_to_rad(angle))
	finished_casting.emit()


func _fire_projectile_at_angle(proj_angle: float) -> void:
	ProjectileFunctions.fire_projectile_at_angle(
		_PROJ_SCENE, proj_angle, character, base_damage, projectile_speed,
		projectile_radius)
