## Represents the Shoot ability which fires a projectile in a direction.
## It is the ability the player always starts with.
class_name Shoot
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 3
var base_damage: int = 20
var projectile_radius: int = 10

func _init():
	super._init(0.5, "res://assets/sprites/shoot.png", "Shoots a projectile.")

## Fires a projectile in a direction.
func perform_ability():
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(projectile_scene, character, projectile_speed, damage, projectile_radius)
	finished_casting.emit()
