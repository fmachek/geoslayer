class_name Coneshot
extends Ability
## Represents the Coneshot ability which fires one regular [Projectile]
## in the middle and two smaller [Projectile]s around it.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Speed of the middle [Projectile].
var projectile_speed: int = 4
## Speed of the smaller [Projectile]s.
var secondary_projectile_speed: int = 3
## Base damage of the middle [Projectile].
var base_damage: int = 20
## Base damage of the smaller [Projectile]s.
var secondary_base_damage: int = 10
## Radius of the middle [Projectile].
var projectile_radius: int = 10
## Radius of the smaller [Projectile]s.
var secondary_projectile_radius: int = 6
## Angle between the smaller [Projectile]s and
## the middle [Projectile] in radians.
var secondary_angle: float = deg_to_rad(15)


func _init() -> void:
	var desc := "Fires one large projectile in the middle and
			two smaller projectiles around it."
	super._init(1.5, desc)


func _perform_ability() -> void:
	var target_pos: Vector2 = character.target_pos
	var target_dir: Vector2 = character.global_position.direction_to(target_pos)
	var target_angle: float = target_dir.angle()
	ProjectileFunctions.fire_projectile_from_character(
			_PROJ_SCENE, character, projectile_speed,
			base_damage, projectile_radius)
	var angle_1: float = target_angle + secondary_angle
	var angle_2: float = target_angle - secondary_angle
	_fire_secondary_projectile(angle_1)
	_fire_secondary_projectile(angle_2)
	finished_casting.emit()


func _fire_secondary_projectile(angle: float) -> void:
	ProjectileFunctions.fire_projectile_at_angle(
			_PROJ_SCENE, angle, character, secondary_base_damage,
			secondary_projectile_speed, secondary_projectile_radius)
