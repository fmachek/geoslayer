class_name Wideshot
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 5
var damage: int = 10
var projectile_radius: int = 6
var projectile_amount = 5
var spread_angle = deg_to_rad(40)

func _init():
	super._init()
	ability_name = "Wideshot"
	cooldown = 1
	texture = load("res://assets/sprites/wideshot.png")
	description = "Shoots projectiles in a cone."

func perform_ability():
	var player_pos: Vector2 = character.global_position
	spawn_projectiles(projectile_amount)
	finished_casting.emit()

func spawn_projectiles(amount):
	var center_direction = (character.target_pos - character.global_position).normalized()
	var center_angle = center_direction.angle()
	var half = int(amount/2) # Rounded half of projectiles
	var half_spread_angle = spread_angle/2
	for i in range(1, half+1):
		var angle = center_angle - i * half_spread_angle/half
		spawn_projectile(angle)
	for i in range(1, half+1):
		var angle = center_angle + i * half_spread_angle/half
		spawn_projectile(angle)
	spawn_projectile(center_angle)

func spawn_projectile(angle):
	var direction = Vector2.from_angle(angle)
		
	var projectile_fill_color: Color = character.draw_color
	var projectile_outline_color: Color = character.outline_color

	var projectile: Projectile = projectile_scene.instantiate()
	projectile.set_properties(projectile_fill_color, projectile_outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
	character.get_parent().add_child(projectile)
