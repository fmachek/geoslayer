class_name Swipe
extends Ability
## Represents the Swipe ability which performs a melee swipe attack
## ([SwipeAttack]).

const _SWIPE_SCENE := preload("res://scenes/objects/attacks/swipe_attack.tscn")

## Base damage dealt by the [SwipeAttack].
var swipe_damage: int = 35
## Length of the [SwipeAttack].
var swipe_length: float = 200.0
## Angle which the [SwipeAttack] covers, in degrees.
var swipe_degrees: float = 120.0
## Time until the [SwipeAttack] reaches its destination.
var swipe_time: float = 0.25


func _init() -> void:
	super(0.5, "Performs a melee swipe attack.")


func _perform_ability() -> void:
	var swipe: SwipeAttack = _create_swipe()
	swipe.finished.connect(func(): finished_casting.emit())
	
	var target_dir := character.global_position.direction_to(character.target_pos)
	var target_angle: float = target_dir.angle()
	swipe.swipe(target_angle, swipe_time)


func _create_swipe() -> SwipeAttack:
	var swipe: SwipeAttack = _SWIPE_SCENE.instantiate()
	swipe.source = character
	swipe.draw_color = Color(character.draw_color, 0.5)
	swipe.base_damage = swipe_damage
	swipe.width = swipe_length
	swipe.swipe_angle = deg_to_rad(swipe_degrees)
	character.add_child(swipe)
	return swipe
