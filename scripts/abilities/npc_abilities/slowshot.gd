class_name Slowshot
extends Ability
## Represents the Slowshot ability which fires a fast [SlowingProjectile].
## This is used by [Slower]s.

const _PROJ_SCENE := preload(
		"res://scenes/objects/projectiles/slowing_projectile.tscn")

## Travel speed of the [SlowingProjectile] fired when cast.
var projectile_speed: int = 6
## Base damage of the [SlowingProjectile] fired when cast.
var base_damage: int = 20
## Radius of the [SlowingProjectile] fired when cast.
var projectile_radius: int = 8


func _init() -> void:
	super._init(0.5, "Fires a slowing projectile.")


## Fires a [SlowingProjectile] in a direction.
func _perform_ability() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	ProjectileFunctions.fire_projectile_from_character(
			_PROJ_SCENE, character, projectile_speed,
			damage, projectile_radius)
	finished_casting.emit()
