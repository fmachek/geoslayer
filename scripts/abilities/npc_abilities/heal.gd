class_name Heal
extends Ability
## Represents the Heal ability which spawns an [AreaHeal] at the
## caster's position. The [AreaHeal] heals [Character]s friendly to
## the caster as well as the caster themself.

const _AREA_HEAL_SCENE := preload("res://scenes/objects/attacks/area_heal.tscn")

## Amount of healing done by the [AreaHeal].
var base_heal_amount: int = 75
## [AreaHeal] radius.
var radius: float = 200.0


func _init() -> void:
	super(4, "Heals friendly characters around the caster.")


func _perform_ability() -> void:
	var heal: AreaHeal = _AREA_HEAL_SCENE.instantiate()
	var char_damage: int = character.damage.max_value_after_buffs
	var heal_amount: int = float(base_heal_amount) * float(char_damage) / 100
	heal.heal_amount = heal_amount
	heal.radius = radius
	heal.source = character
	heal.global_position = character.global_position
	character.get_parent().add_child(heal)
	finished_casting.emit()
