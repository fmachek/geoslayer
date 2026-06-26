class_name Return
extends Ability

var boomerang_scene: PackedScene = preload(
	"res://scenes/objects/boomerangs/boomerang.tscn"
)
var boomerang_damage: int = 30
var boomerang_travel_speed: float = 600.0
var boomerang_return_time: float = 0.75


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_description: String = "Throws a boomerang which returns to the caster."
	var ability_cast_duration: float = 0.0
	super(ability_cooldown, ability_cast_duration, ability_description)


func _perform_ability() -> void:
	var boomerang: Boomerang = boomerang_scene.instantiate()
	boomerang.caster = character
	var direction := (character.target_pos - character.global_position).normalized()
	boomerang.travel_direction = direction
	boomerang.base_damage = boomerang_damage
	boomerang.travel_speed = boomerang_travel_speed
	boomerang.return_time = boomerang_return_time
	boomerang.global_position = character.global_position
	character.get_parent().add_child(boomerang)
	finished_casting.emit()


func _handle_casting() -> void:
	pass
