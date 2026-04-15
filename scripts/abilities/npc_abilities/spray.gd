class_name Spray
extends Ability
## Represents the Spray ability which fires multiple [DoTProjectile]s in
## quick succession.
##
## Two projectiles are fired at once, at opposing sides of the attack pattern.
## The projectiles are also slower the later they are fired.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/dot_projectile.tscn")

## Base speed of the [DoTProjectile]s before a speed decrease is applied.
var projectile_speed: float = 3
## Base damage of the [DoTProjectile]s.
var base_damage: int = 5
## Radius of the [DoTProjectile]s.
var projectile_radius: int = 6
## Amount of [DoTProjectile]s fired on each cast.
var projectile_amount: int = 9
## Time between firing individual [DoTProjectile]s, in seconds.
var fire_time: float = 0.1
## Spread of the attack pattern in radians.
var spread: float = deg_to_rad(90)
## Damage dealt by [member DoTProjectile.dot] on every tick.
var dot_damage: int = 1
## Time between individual [member DoTProjectile.dot] ticks.
var dot_tick_time: float = 1.0
## Total amount of [member DoTProjectile.dot] ticks.
var dot_tick_amount: int = 5

var _fire_timer: Timer
var _proj_angles: Array[float] = []
var _proj_speed_decrease: float


func _init() -> void:
	super(2, "Fires projectiles which deal damage over time.")


func _ready() -> void:
	_create_fire_timer()


func _perform_ability() -> void:
	_proj_speed_decrease = 0
	_generate_angles()
	_fire_timer.start()
	_fire_at_angles()


func _reset_ability() -> void:
	if _fire_timer:
		_fire_timer.stop()


func _fire_projectile(angle: float) -> void:
	var proj: DoTProjectile = ProjectileFunctions.fire_projectile_at_angle(
			_PROJ_SCENE, angle, character, base_damage,
			(projectile_speed - _proj_speed_decrease), projectile_radius
	)
	var dot := DamageOverTime.new(dot_damage, dot_tick_time, dot_tick_amount)
	proj.dot = dot


func _fire_at_angles() -> void:
	_proj_speed_decrease += 0.2
	if len(_proj_angles) > 1:
		var angle_1: float = _proj_angles.pop_front()
		var angle_2: float = _proj_angles.pop_back()
		_fire_projectile(angle_1)
		_fire_projectile(angle_2)
	elif len(_proj_angles) > 0:
		var angle: float = _proj_angles.pop_front()
		_fire_projectile(angle)
	else:
		_finish_firing()


func _generate_angles() -> void:
	var target_pos: Vector2 = character.target_pos
	var target_dir: Vector2 = character.global_position.direction_to(target_pos)
	var target_angle: float = target_dir.angle()
	var start_angle: float = target_angle - spread / 2
	_proj_angles.clear()
	for i in range(projectile_amount):
		_proj_angles.append(start_angle + i * (spread / projectile_amount))


func _finish_firing() -> void:
	_fire_timer.stop()
	finished_casting.emit()


func _create_fire_timer() -> void:
	_fire_timer = Timer.new()
	_fire_timer.wait_time = fire_time
	_fire_timer.timeout.connect(_fire_at_angles)
	add_child(_fire_timer)
