class_name Smash
extends Ability
## Represents the Smash ability which uses a [SmashArea] to
## stun, deal damage to and knock nearby enemies back.

var _AREA_SCENE := preload("res://scenes/objects/attacks/smash_area.tscn")

## Base damage dealt by the [SmashArea].
var base_damage: int = 50
## Radius of the [SmashArea].
var radius: float = 250.0
## Duration of the stun applied by the [SmashArea].
var stun_duration: float = 1.0
## Amount of knockback applied by the [SmashArea].
var knockback: float = 500.0


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_cast_time: float = 0.0
	var ability_description := "Stuns, deals damage to and knocks nearby enemies back."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	var area: SmashArea = _prepare_area()
	character.get_parent().add_child(area)
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _prepare_area() -> SmashArea:
	var area: SmashArea = _AREA_SCENE.instantiate()
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	area.damage = damage
	area.radius = radius
	area.source = character
	area.global_position = character.global_position
	area.stun_duration = stun_duration
	area.knockback = knockback
	area.draw_color = Color(character.draw_color, 0.1).darkened(0.3)
	area.outline_color = Color(character.draw_color, 0.3).darkened(0.3)
	return area
