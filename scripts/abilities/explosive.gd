class_name Explosive
extends Ability

## Represents the Explosive ability which fires a [Grenade] which deals damage and explodes
## into more [GrenadeProjectile] projectiles on impact.

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/grenade.tscn")
var projectile_speed: int = 3
var base_damage: int = 15
var projectile_radius: int = 15

func _init():
	super._init(0.5, "res://assets/sprites/grenade.png", "Fires a grenade which explodes on impact.")

## Fires one [Grenade].
func perform_ability():
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(projectile_scene, character, projectile_speed, damage, projectile_radius)
	finished_casting.emit()
