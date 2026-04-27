class_name Stunshot
extends Ability
## Represents the Stunshot ability which fires one large [StunProjectile]
## followed by two regular [Projectile]s.

const _STUN_PROJ_SCENE := preload(
		"res://scenes/objects/projectiles/stun_projectile.tscn")
const _REG_PROJ_SCENE := preload(
		"res://scenes/objects/projectiles/projectile.tscn")

## Speed of the [Projectile]s fired.
var projectile_speed: int = 4

## Base damage dealt by the [StunProjectile].
var stun_projectile_base_damage: int = 10
## Radius of the [StunProjectile].
var stun_projectile_radius: int = 14
## Duration of the stun applied by the [StunProjectile] in seconds.
var stun_duration: float = 2.0

## Base damage dealt by the regular [Projectile]s fired.
var regular_projectile_base_damage: int = 10
## Radius of the regular [Projectile]s fired.
var regular_projectile_radius: int = 10
## Amount of regular [Projectile]s fired.
var regular_projectile_amount: int = 2

## Amount of time which passes between firing individual
## [Projectile]s, in seconds.
var fire_time: float = 0.2

var _fire_timer: Timer
var _reg_projectiles_remaining: int


func _init() -> void:
	var description := "Fires a stunning projectile followed by two regular ones."
	super(3.0, description)


func _ready() -> void:
	_create_fire_timer()


func _perform_ability() -> void:
	_reg_projectiles_remaining = regular_projectile_amount
	_fire_stun_projectile()
	_fire_timer.start()


func _reset_ability() -> void:
	if _fire_timer:
		_fire_timer.stop()
	_reg_projectiles_remaining = regular_projectile_amount


func _fire_stun_projectile() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(stun_projectile_base_damage) * float(char_damage) / 100
	var proj: StunProjectile = ProjectileFunctions.fire_projectile_from_character(
			_STUN_PROJ_SCENE, character, projectile_speed,
			damage, stun_projectile_radius)
	proj.stun_duration = stun_duration


func _fire_regular_projectile() -> void:
	if _reg_projectiles_remaining > 0:
		_reg_projectiles_remaining -= 1
		var char_damage: int = character.damage.max_value_after_buffs
		var damage: int = float(regular_projectile_base_damage) * float(char_damage) / 100
		ProjectileFunctions.fire_projectile_from_character(
				_REG_PROJ_SCENE, character, projectile_speed,
				damage, regular_projectile_radius)
	else:
		_fire_timer.stop()
		finished_casting.emit()


func _on_fire_timer_timeout() -> void:
	_fire_regular_projectile()


func _create_fire_timer() -> void:
	_fire_timer = Timer.new()
	_fire_timer.wait_time = fire_time
	_fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(_fire_timer)
