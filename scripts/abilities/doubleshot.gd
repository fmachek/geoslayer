class_name Doubleshot
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 3
var damage: int = 15
var projectile_radius: int = 8

func _init():
	super._init()
	ability_name = "Doubleshot"
	cooldown = 0.75
	texture = load("res://assets/sprites/placeholder.png")
	description = "Shoots two projectiles."

func perform_ability():
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	
	var direction_to_mouse = (target_pos - player_pos).normalized()
	var projectile1_pos = player_pos + direction_to_mouse
	
	var angle_to_mouse = direction_to_mouse.angle()
	
	var distance_to_projectiles = projectile_radius*2
	var direction_to_projectile_1 = direction_to_mouse.rotated(-90)
	var direction_to_projectile_2 = direction_to_mouse.rotated(90)
	var p1_pos = character.global_position + direction_to_projectile_1*distance_to_projectiles
	var p2_pos = character.global_position + direction_to_projectile_2*distance_to_projectiles
	
	spawn_projectile(p1_pos, direction_to_mouse)
	spawn_projectile(p2_pos, direction_to_mouse)
	finished_casting.emit()

func spawn_projectile(pos: Vector2, direction: Vector2):
	var projectile: Projectile = projectile_scene.instantiate()
	var projectile_fill_color: Color = character.draw_color
	var projectile_outline_color: Color = character.outline_color
	projectile.set_properties(projectile_fill_color, projectile_outline_color, direction, projectile_speed, character, damage, projectile_radius, pos)
	character.get_parent().add_child(projectile)
