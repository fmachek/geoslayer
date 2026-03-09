class_name Doubleshot
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 3
var base_damage: int = 15
var projectile_radius: int = 8

func _init():
	super._init()
	ability_name = "Doubleshot"
	cooldown = 0.75
	texture = load("res://assets/sprites/doubleshot.png")
	description = "Shoots two projectiles."

func perform_ability():
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	
	var direction_to_target = (target_pos - player_pos).normalized()
	var projectile1_pos = player_pos + direction_to_target
	
	var angle_to_target = direction_to_target.angle()
	
	var distance_to_projectiles = projectile_radius*2
	var direction_to_projectile_1 = direction_to_target.rotated(-90)
	var direction_to_projectile_2 = direction_to_target.rotated(90)
	var p1_pos = character.global_position + direction_to_projectile_1*distance_to_projectiles
	var p2_pos = character.global_position + direction_to_projectile_2*distance_to_projectiles
	
	spawn_projectile(p1_pos, direction_to_target)
	spawn_projectile(p2_pos, direction_to_target)
	finished_casting.emit()

func spawn_projectile(pos: Vector2, direction: Vector2):
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	var projectile_properties: ProjectileProperties = ProjectileProperties.new(character.draw_color, character.outline_color, direction, projectile_speed, character, damage, projectile_radius, pos)
	ProjectileFunctions.fire_projectile(projectile_scene, projectile_properties)
