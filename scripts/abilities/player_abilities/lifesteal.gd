class_name Lifesteal
extends Ability
## Represents the Lifesteal ability which fires multiple projectiles
## in quick succession which deal damage to enemies and heal the caster
## for a portion of the damage dealt.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/lifesteal_projectile.tscn")

## Travel speed of the [LifestealProjectile] fired when cast.
var projectile_speed: int = 3
## Base damage of the [LifestealProjectile] fired when cast.
var base_damage: int = 10
## Radius of the [LifestealProjectile] fired when cast.
var projectile_radius: int = 8
## Amount of [LifestealProjectile]s fired on each cast.
var projectile_amount: int = 3
## Time between the firing of individual [LifestealProjectile]s.
var fire_time: float = 0.2

var _fire_timer: Timer
var _projectiles_remaining: int


func _init() -> void:
	var description := "Fires %d projectiles which heal the 
			caster if they hit an enemy." % projectile_amount
	super._init(1, description)


func _ready() -> void:
	_create_fire_timer()


func _create_fire_timer() -> void:
	_fire_timer = Timer.new()
	_fire_timer.wait_time = fire_time
	_fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(_fire_timer)


# Shoots a projectile on every fire timer timeout.
func _on_fire_timer_timeout() -> void:
	_fire_projectile()


func _perform_ability() -> void:
	_projectiles_remaining = projectile_amount
	_fire_timer.start()
	_fire_projectile()


# Fires a projectile if there are projectiles remaining. Otherwise
# the ability stops shooting and finishes casting.
func _fire_projectile() -> void:
	if _projectiles_remaining > 0:
		_projectiles_remaining -= 1
		var char_damage: int = character.damage.max_value_after_buffs
		var damage: int = float(base_damage) * float(char_damage) / 100
		ProjectileFunctions.fire_projectile_from_character(
				_PROJ_SCENE, character, projectile_speed,
				damage, projectile_radius)
	else:
		_fire_timer.stop()
		finished_casting.emit()


func _reset_ability() -> void:
	if _fire_timer:
		_fire_timer.stop()
	_projectiles_remaining = projectile_amount
