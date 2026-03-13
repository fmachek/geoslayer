## Represents the Flurry ability which fires a flurry of projectiles. While casting, the caster
## is unable to cast other abilities. Tha ability also has a bit of a random recoil (the projectiles
## fire in a slightly offset direction).
class_name Flurry
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 4
var base_damage: int = 7
var projectile_radius: int = 5

## Amount of projectiles fired by the ability.
var projectile_amount: int = 20
## Amount of projectiles remaining during the cast.
var projectiles_remaining: int
## Timer used to time firing the individual projectiles.
var flurry_timer: Timer
## Time between individual projectile firing.
var flurry_fire_time: float = 0.1
## Maximum projectile recoil in angles.
var recoil: int = 10

func _init() -> void:
	super._init(4, "res://assets/sprites/flurry.png", "Fires a flurry of projectiles.")

## Creates the flurry timer when entering the scene tree.
func _ready() -> void:
	_create_flurry_timer()

## Creates the flurry timer used to time firing the individual projectiles. It is added
## as a child of the ability.
func _create_flurry_timer() -> void:
	flurry_timer = Timer.new()
	flurry_timer.wait_time = flurry_fire_time
	flurry_timer.timeout.connect(_on_flurry_timer_timeout)
	add_child(flurry_timer)

## Resets projectiles_remaining, starts the flurry timer and instantly
## fires the first projectile.
func perform_ability() -> void:
	projectiles_remaining = projectile_amount
	flurry_timer.start()
	shoot_projectile()

## Shoots a projectile on every flurry timer timeout.
func _on_flurry_timer_timeout() -> void:
	shoot_projectile()

## Fires a single projectile if there are projectiles remaining.
## Every projectile has a random offset applied to its direction to simulate recoil.
## If there are no projectiles remaining, the flurry timer stops.
func shoot_projectile() -> void:
	if projectiles_remaining > 0:
		projectiles_remaining -= 1
		var target_pos: Vector2 = character.target_pos
		var player_pos: Vector2 = character.global_position
		
		var direction_to_target := (target_pos - player_pos).normalized()
		var random_angle = randf_range(-recoil/2, recoil/2)
		var direction = direction_to_target.rotated(deg_to_rad(random_angle))
		
		var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
		var projectile_properties: ProjectileProperties = ProjectileProperties.new(character.draw_color, character.outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
		ProjectileFunctions.fire_projectile(projectile_scene, projectile_properties)
	else:
		flurry_timer.stop()
		finished_casting.emit()

## Overriden function used to reset the Ability to its default state. In this case,
## the projectiles_remaining variable must be reset to the default projectile_amount.
## The flury timer is also stopped.
func _reset_ability() -> void:
	if flurry_timer:
		flurry_timer.stop()
	projectiles_remaining = projectile_amount
