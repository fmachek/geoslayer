class_name Fortify
extends Ability
## Represents the Fortify ability which spawns a [Shield] around the caster
## which expires when [member shield_duration] passes.

const _SHIELD_SCENE := preload("res://scenes/objects/shields/shield.tscn")

## Time until the [Shield] disappears, in seconds.
var shield_duration: float = 5.0
## Radius of the [Shield].
var shield_radius: float = 82.0


func _init() -> void:
	super(10.0, "Shields the caster from incoming attacks for %d seconds." % shield_duration)


func _perform_ability() -> void:
	_spawn_shield()
	finished_casting.emit()


func _spawn_shield() -> void:
	var shield: Shield = _SHIELD_SCENE.instantiate()
	shield.expiration_time = shield_duration
	shield.radius = shield_radius
	character.add_child(shield)
