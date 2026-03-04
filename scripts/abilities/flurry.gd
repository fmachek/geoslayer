class_name Flurry
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 4
var base_damage: int = 7
var projectile_radius: int = 5
var projectile_amount: int = 20
var flurry_timer: Timer
var projectiles_remaining: int
var flurry_fire_time: float = 0.1
var recoil: int = 10

func _ready():
	flurry_timer = Timer.new()
	flurry_timer.wait_time = flurry_fire_time
	flurry_timer.timeout.connect(_on_flurry_timer_timeout)
	add_child(flurry_timer)

func _init():
	super._init()
	ability_name = "Flurry"
	cooldown = 4
	texture = load("res://assets/sprites/placeholder.png")
	description = "Fires a flurry of projectiles."

func perform_ability():
	projectiles_remaining = projectile_amount
	flurry_timer.start()
	shoot_projectile()

func _on_flurry_timer_timeout():
	shoot_projectile()

func shoot_projectile():
	if projectiles_remaining > 0:
		projectiles_remaining -= 1
		var target_pos: Vector2 = character.target_pos
		var player_pos: Vector2 = character.global_position
		
		var direction_to_mouse := (target_pos - player_pos).normalized()
		var random_angle = randf_range(-recoil/2, recoil/2)
		var direction = direction_to_mouse.rotated(deg_to_rad(random_angle))
		
		var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
		var projectile_properties: ProjectileProperties = ProjectileProperties.new(character.draw_color, character.outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
		ProjectileFunctions.fire_projectile(projectile_properties)
	else:
		flurry_timer.stop()
		finished_casting.emit()

func reset_ability():
	if flurry_timer:
		flurry_timer.stop()
	projectiles_remaining = projectile_amount
