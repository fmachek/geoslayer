class_name Shoot
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 3
var damage: int = 20
var projectile_radius: int = 10

func _init():
	super._init()
	ability_name = "Shoot"
	cooldown = 0.5
	texture = load("res://assets/sprites/shoot.png")
	description = "Shoots a projectile."

func perform_ability():
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	var direction = (target_pos - player_pos).normalized()
	var projectile: Projectile = projectile_scene.instantiate()
	var projectile_fill_color: Color = character.draw_color
	var projectile_outline_color: Color = character.outline_color
	projectile.set_properties(projectile_fill_color, projectile_outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
	character.get_parent().add_child(projectile)
	finished_casting.emit()
