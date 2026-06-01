class_name Flee
extends Ability

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

var projectile_speed: float = 5.0
var base_damage: int = 15
var projectile_radius: float = 7.0
var projectile_knockback: float = 400.0
var caster_knockback: float = -1250.0

var projectile_amount: int = 3
var spread_angle: float = deg_to_rad(20)


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_cast_time: float = 0.0
	var ability_description := "Fires %d projectiles and knocks the caster back in the \
			opposite direction." % projectile_amount
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	_fire_projectiles()
	_apply_knockback()
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _fire_projectiles() -> void:
	var projectiles := ProjectileFunctions.fire_projectile_cone(
			_PROJ_SCENE, projectile_amount, spread_angle,
			character, base_damage, projectile_speed, projectile_radius)
	for proj in projectiles:
		proj.knockback = projectile_knockback


func _apply_knockback() -> void:
	var target_pos: Vector2 = character.target_pos
	var dir_to_target_pos := character.global_position.direction_to(target_pos)
	var normalized := dir_to_target_pos.normalized()
	character.apply_knockback(caster_knockback * normalized)
