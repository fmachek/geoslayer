class_name Shoot
extends Ability

## Represents the Shoot ability which fires a [Projectile] in a direction.
## The [Projectile] applies a slight knockback.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile] fired when cast.
var projectile_speed: int = 3
## Base damage of the [Projectile] fired when cast.
var base_damage: int = 20
## Radius of the [Projectile] fired when cast.
var projectile_radius: int = 10
## Knockback applied to [Character]s hit by the [Projectile].
var projectile_knockback: float = 350.0


func _init() -> void:
	super._init(0.5, "Shoots a projectile.")


## Fires a [Projectile] in a direction.
func _perform_ability() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var proj := ProjectileFunctions.fire_projectile_from_character(
			_PROJ_SCENE, character, projectile_speed,
			damage, projectile_radius)
	proj.knockback = projectile_knockback
	finished_casting.emit()
