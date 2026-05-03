class_name Protect
extends Ability
## Represents the Protect ability which applies a [Shield] to the caster's
## allies standing inside the application area.

const _APPLICATION_AREA_SCENE := preload(
		"res://scenes/objects/attacks/shield_application_area.tscn")

## Radius of the [ShieldApplicationArea].
var area_radius: float = 300.0
## Duration of the [Shield]s applied.
var shield_duration: float = 2.0
## Radius of the [Shield]s applied.
var shield_radius: float = 82.0
## Durability of the [Shield]s applied.
var shield_durability: int = 1


func _init() -> void:
	super(2.5, "Applies a shield to nearby allies.")


func _perform_ability() -> void:
	var area: ShieldApplicationArea = _APPLICATION_AREA_SCENE.instantiate()
	area.radius = area_radius
	area.source = character
	area.shield_duration = shield_duration
	area.shield_radius = shield_radius
	area.shield_durability = shield_durability
	area.global_position = character.global_position
	character.get_parent().add_child(area)
	finished_casting.emit()
