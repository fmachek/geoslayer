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
	var desc := "Fires two projectiles in different directions."
	super(0.5, "res://assets/sprites/placeholder.png", desc)


func _perform_ability() -> void:
	var dir_to_target: Vector2 = character.global_position.direction_to(character.target_pos)
	var angle_to_target: float = dir_to_target.angle()
	_fire_projectile_in_angle(angle_to_target + deg_to_rad(-angle))
	_fire_projectile_in_angle(angle_to_target + deg_to_rad(angle))
	finished_casting.emit()


func _fire_projectile_in_angle(angle: float) -> void:
	var direction = Vector2.from_angle(angle)
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var projectile_properties := ProjectileProperties.new(
			character.draw_color, character.outline_color,
			direction, projectile_speed, character, damage,
			projectile_radius, character.global_position)
	ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
