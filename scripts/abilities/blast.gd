class_name Blast
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 2
var base_damage: int = 10
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
		var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
		var projectile_properties: ProjectileProperties = ProjectileProperties.new(character.draw_color, character.outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
		ProjectileFunctions.fire_projectile(projectile_properties)
