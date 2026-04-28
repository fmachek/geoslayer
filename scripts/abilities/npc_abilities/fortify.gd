class_name Fortify
extends Ability
## Represents the Fortify ability which spawns a [Shield] around the caster
## which expires when [member shield_duration] passes.

const _SHIELD_SCENE := preload("res://scenes/objects/shields/shield.tscn")

## Time until the [Shield] disappears, in seconds.
var shield_duration: float = 2.5
## Radius of the [Shield].
var shield_radius: float = 82.0
## Base durability of the [Shield].
var shield_base_durability: int = 50


func _init() -> void:
	super(7.5, "Shields the caster from enemy projectiles for %d seconds." % shield_duration)


func _perform_ability() -> void:
	_spawn_shield()
	finished_casting.emit()


func _spawn_shield() -> void:
	var shield: Shield = _SHIELD_SCENE.instantiate()
	shield.expiration_time = shield_duration
	shield.radius = shield_radius
	var caster_level: int = character.level.current_level
	var shield_durability: int = shield_base_durability * pow(1.25, caster_level)
	shield.durability = shield_durability
	character.add_child(shield)
