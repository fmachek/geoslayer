class_name Blast
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 2
var damage: int = 10
var projectile_radius: int = 12
var projectile_amount = 20

func _init():
	super._init()
	ability_name = "Blast"
	cooldown = 2
	texture = load("res://assets/sprites/blast.png")
	description = "Shoots projectiles in all directions."

func perform_ability():
	var player_pos: Vector2 = character.global_position
	spawn_projectiles(projectile_amount)
	finished_casting.emit()

func spawn_projectiles(amount):
	for i in range(amount):
		# Calculate the angle for this specific projectile
		var angle = i * (TAU / amount)
		
		# Create a direction vector from that angle
		var direction = Vector2.from_angle(angle)
		
		var projectile_fill_color: Color = character.draw_color
		var projectile_outline_color: Color = character.outline_color

		var projectile: Projectile = projectile_scene.instantiate()
		projectile.set_properties(projectile_fill_color, projectile_outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
		character.get_parent().add_child(projectile)
