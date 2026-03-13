## Represents the Doubleshot ability which fires two projectiles next to each other.
class_name Doubleshot
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 3
var base_damage: int = 15
var projectile_radius: int = 8

func _init() -> void:
	super._init(0.75, "res://assets/sprites/doubleshot.png", "Shoots two projectiles.")

## Fires two projectiles next to each other.
func perform_ability() -> void:
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	
	# Calculates the angle to the target position, derived from the direction.
	var direction_to_target = (target_pos - player_pos).normalized()
	var angle_to_target = direction_to_target.angle()
	
	# Distance from the Character's position to the projectiles (half the radius).
	# It is also the distance between the two projectiles (divided by 2).
	var distance_to_projectiles = projectile_radius*2
	var direction_to_projectile_1 = direction_to_target.rotated(-90)
	var direction_to_projectile_2 = direction_to_target.rotated(90)
	
	# Calculates the two projectiles' positions.
	var p1_pos = character.global_position + direction_to_projectile_1*distance_to_projectiles
	var p2_pos = character.global_position + direction_to_projectile_2*distance_to_projectiles
	
	spawn_projectile(p1_pos, direction_to_target)
	spawn_projectile(p2_pos, direction_to_target)
	finished_casting.emit()

## Fires one projectile in a direction from a given position.
func spawn_projectile(pos: Vector2, direction: Vector2) -> void:
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	var projectile_properties: ProjectileProperties = ProjectileProperties.new(character.draw_color, character.outline_color, direction, projectile_speed, character, damage, projectile_radius, pos)
	ProjectileFunctions.fire_projectile(projectile_scene, projectile_properties)
