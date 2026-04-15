class_name Orbit
extends Ability
## Represents the Orbit ability which spawns a [LaserCross] at
## the caster's position. The [LaserCross] follows the caster around.

const _LASER_PATH := "res://scenes/objects/lasers/laser_cross.tscn"
const _LASER_CROSS_SCENE := preload(_LASER_PATH)

## Base amount of damage dealt by the [Laser]s.
var laser_base_damage: int = 10
## Time until the [LaserCross] disappears.
var laser_lifetime: float = 5.0


func _init() -> void:
	super(15, "Spawns 4 lasers which orbit around the caster.")


func _perform_ability() -> void:
	var damage_multiplier: float = float(character.damage.max_value_after_buffs) / 100
	var laser_damage: int = float(laser_base_damage) * damage_multiplier
	
	var laser_cross: LaserCross = _LASER_CROSS_SCENE.instantiate()
	laser_cross.lifetime = laser_lifetime
	laser_cross.source = character
	laser_cross.damage = laser_damage
	character.add_child(laser_cross)
	laser_cross.global_position = character.global_position
	
	finished_casting.emit()
