class_name Explosive
extends Ability

## Represents the Explosive ability which fires a [Grenade] which deals damage and explodes
## into more [GrenadeProjectile] projectiles on impact.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/grenade.tscn")

## Travel speed of the [Projectile] fired when cast.
var projectile_speed: int = 3
## Base damage of the [Projectile] fired when cast.
var base_damage: int = 15
## Radius of the [Projectile] fired when cast.
var projectile_radius: int = 15


func _init() -> void:
	super._init(0.5, "Fires a grenade which explodes on impact.")


## Fires one [Grenade].
func _perform_ability() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	ProjectileFunctions.fire_projectile_from_character(
			_PROJ_SCENE, character,
			projectile_speed, damage,
			projectile_radius)
	finished_casting.emit()
