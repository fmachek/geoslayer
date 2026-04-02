class_name Doubleshot
extends Ability

## Represents the Doubleshot ability which fires two projectiles next to each other.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile]s fired when cast.
var projectile_speed: int = 3
## Base damage of the [Projectile]s fired when cast.
var base_damage: int = 15
## Radius of the [Projectile]s fired when cast.
var projectile_radius: int = 8


func _init() -> void:
	super._init(0.75, "Shoots two projectiles.")


## Fires two [Projectile]s next to each other.
func _perform_ability() -> void:
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	
	# Calculates the angle to the target position, derived from the direction.
	var direction_to_target: Vector2 = (target_pos - player_pos).normalized()
	var angle_to_target: float = direction_to_target.angle()
	
	# Distance from the caster's position to the projectiles (half the radius).
	# It is also half the distance between thtwo projectiles.
	var distance_to_projectiles: int = projectile_radius * 2
	var direction_to_projectile_1: Vector2 = direction_to_target.rotated(-90)
	var direction_to_projectile_2: Vector2 = direction_to_target.rotated(90)
	
	# Calculates the two projectiles' positions.
	var p1_pos: Vector2 = character.global_position + direction_to_projectile_1 * distance_to_projectiles
	var p2_pos: Vector2 = character.global_position + direction_to_projectile_2 * distance_to_projectiles
	
	_spawn_projectile(p1_pos, direction_to_target)
	_spawn_projectile(p2_pos, direction_to_target)
	finished_casting.emit()


## Fires one [Projectile] in a [param direction] from a given [param position].
func _spawn_projectile(position: Vector2, direction: Vector2) -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var projectile_properties := ProjectileProperties.new(
			character.draw_color, character.outline_color,
			direction, projectile_speed,
			character, damage,
			projectile_radius, position)
	ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
