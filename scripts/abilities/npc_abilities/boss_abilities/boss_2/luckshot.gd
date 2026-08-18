class_name Luckshot
extends Ability

var proj_scene := preload("res://scenes/objects/projectiles/projectile.tscn")

var projectile_speed_min: float = 1.5
var projectile_speed_max: float = 2.5
var projectile_amount_min: int = 6
var projectile_amount_max: int = 10
var projectile_radius_min: float = 7.0
var projectile_radius_max: float = 10.0
var projectile_knockback: float = 100.0
var spread_angle_min: float = deg_to_rad(90)
var spread_angle_max: float = deg_to_rad(135)
var base_damage: int = 15


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_cast_time: float = 0.0
	var ability_description := "Fires projectiles in a cone. Various properties are randomized."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	var projectile_amount: int = randi_range(
			projectile_amount_min,
			projectile_amount_max
	)
	var projectile_speed: float = randf_range(
			projectile_speed_min,
			projectile_speed_max
	)
	var projectile_radius: float = randf_range(
			projectile_radius_min,
			projectile_radius_max
	)
	var spread_angle: float = randf_range(
			spread_angle_min,
			spread_angle_max
	)
	var projectiles := ProjectileFunctions.fire_projectile_cone(
			proj_scene, projectile_amount, spread_angle,
			character, base_damage, projectile_speed, projectile_radius)
	for proj in projectiles:
		proj.knockback = projectile_knockback
	finished_casting.emit()


func _handle_casting() -> void:
	pass
