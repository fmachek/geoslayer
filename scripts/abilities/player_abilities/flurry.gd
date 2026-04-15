class_name Flurry
extends Ability
## Represents the Flurry ability which fires a flurry of projectiles.
## While casting, the caster is unable to cast other abilities.
## The ability also has a random recoil (the projectiles fire in a
## slightly offset direction). Each of the projectiles also applies
## a slight knockback.

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
## Knockback applied to [Character]s hit by the [Projectile]s.
var projectile_knockback: float = 200.0

# Amount of projectiles remaining during the cast.
var _projectiles_remaining: int
# Used to time firing the individual projectiles.
var _flurry_timer: Timer


func _init() -> void:
	super(4, "Fires a flurry of projectiles.")


func _ready() -> void:
	_create_flurry_timer()


func _perform_ability() -> void:
	_projectiles_remaining = projectile_amount
	_flurry_timer.start()
	_fire_projectile()


func _reset_ability() -> void:
	if _flurry_timer:
		_flurry_timer.stop()
	_projectiles_remaining = projectile_amount


func _fire_projectile() -> void:
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
		var proj := ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
		proj.knockback = projectile_knockback
	else:
		_flurry_timer.stop()
		finished_casting.emit()


func _create_flurry_timer() -> void:
	_flurry_timer = Timer.new()
	_flurry_timer.wait_time = flurry_fire_time
	_flurry_timer.timeout.connect(_on_flurry_timer_timeout)
	add_child(_flurry_timer)


# Fires a projectile on every flurry timer timeout.
func _on_flurry_timer_timeout() -> void:
	_fire_projectile()
