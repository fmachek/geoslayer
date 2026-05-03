class_name Mirrorshot
extends Ability
## Represents the Mirrorshot ability which fires multiple [Projectile]s at
## mirroring angles.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Speed of the [Projectile]s fired on cast.
var projectile_speed: float = 1.5
## Base damage of the [Projectile]s fired on cast.
var base_damage: int = 15
## Radius of the [Projectile]s fired on cast.
var projectile_radius: int = 8
## Amount of [Projectile] fire steps.
var step_amount: int = 10
## Amount of time between the firing of individual [Projectile]s,
## in seconds.
var fire_time: float = 0.1

var _fire_timer: Timer
var _current_step: int = 0


func _init() -> void:
	super(2.0, "Fires many projectiles in opposite directions.")


func _ready() -> void:
	_create_fire_timer()


func _perform_ability() -> void:
	_current_step = 0
	_fire_timer.start()
	_fire_projectiles()


func _reset_ability() -> void:
	if _fire_timer:
		_fire_timer.stop()
	_current_step = 0


func _fire_projectiles() -> void:
	var angle: float = _current_step * (TAU / step_amount / 2)
	var mirror_angle: float = angle + deg_to_rad(180)
	_fire_projectile_at_angle(angle)
	_fire_projectile_at_angle(mirror_angle)
	_current_step += 1
	if _current_step == step_amount:
		_stop_firing()


func _fire_projectile_at_angle(angle: float) -> void:
	ProjectileFunctions.fire_projectile_at_angle(
		_PROJ_SCENE, angle, character, base_damage, projectile_speed,
		projectile_radius)


func _stop_firing() -> void:
	_fire_timer.stop()
	finished_casting.emit()


func _create_fire_timer() -> void:
	if not is_instance_valid(_fire_timer):
		_fire_timer = Timer.new()
		_fire_timer.wait_time = fire_time
		_fire_timer.timeout.connect(_on_fire_timer_timeout)
		add_child(_fire_timer)


func _on_fire_timer_timeout() -> void:
	_fire_projectiles()
