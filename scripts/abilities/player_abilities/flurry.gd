class_name Flurry
extends Ability

## Represents the Flurry ability which fires a flurry of projectiles.
## While casting, the caster is unable to cast other abilities.
## ability also has a random recoil (the projectiles fire in a
## slightly offset direction).

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile]s fired when cast.
var projectile_speed: int = 4
## Base damage of the [Projectile]s fired when cast.
var base_damage: int = 7
## Radius of the [Projectile]s fired when cast.
var projectile_radius: int = 5

## Amount of projectiles fired on each cast.
var projectile_amount: int = 20
## Time between the firing of individual projectiles.
var flurry_fire_time: float = 0.1
## Maximum projectile recoil angle in degrees.
var recoil: int = 10

# Amount of projectiles remaining during the cast.
var _projectiles_remaining: int
# Used to time firing the individual projectiles.
var _flurry_timer: Timer


func _init() -> void:
	super._init(4, "res://assets/sprites/flurry.png", "Fires a flurry of projectiles.")


func _ready() -> void:
	_create_flurry_timer()


func _create_flurry_timer() -> void:
	_flurry_timer = Timer.new()
	_flurry_timer.wait_time = flurry_fire_time
	_flurry_timer.timeout.connect(_on_flurry_timer_timeout)
	add_child(_flurry_timer)


func _perform_ability() -> void:
	_projectiles_remaining = projectile_amount
	_flurry_timer.start()
	_shoot_projectile()


# Shoots a projectile on every flurry timer timeout.
func _on_flurry_timer_timeout() -> void:
	_shoot_projectile()


## Fires a single [Projectile] if there are projectiles remaining.
## Every [Projectile] has a random offset applied to its direction to simulate recoil.
## If there are no projectiles remaining, the flurry timer stops.
func _shoot_projectile() -> void:
	if _projectiles_remaining > 0:
		_projectiles_remaining -= 1
		var target_pos: Vector2 = character.target_pos
		var player_pos: Vector2 = character.global_position
		
		var direction_to_target := (target_pos - player_pos).normalized()
		var random_angle: float = randf_range(-recoil/2, recoil/2)
		var direction: Vector2 = direction_to_target.rotated(deg_to_rad(random_angle))
		
		var char_damage: int = character.damage.max_value_after_buffs
		var damage: int = float(base_damage) * float(char_damage) / 100
		var projectile_properties := ProjectileProperties.new(
				character.draw_color, character.outline_color,
				direction, projectile_speed, character,
				damage, projectile_radius,
				character.global_position)
		ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
	else:
		_flurry_timer.stop()
		finished_casting.emit()


## Overriden function used to reset the [Ability] to its default state. In this case,
## [member Flurry._projectiles_remaining] must be reset to [member Flurry.projectile_amount].
## The flurry timer is also stopped.
func _reset_ability() -> void:
	if _flurry_timer:
		_flurry_timer.stop()
	_projectiles_remaining = projectile_amount
