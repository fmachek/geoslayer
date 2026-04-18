class_name Pierce
extends Ability
## Represents the Pierce ability which fires a piercing,
## high-damage projectile with a unique look. The caster
## needs to aim for a bit before firing the projectile.
## The projectile also applies a knockback.

const _PROJ_SCENE_PATH := "res://scenes/objects/projectiles/piercing_projectile.tscn"
const _PROJ_SCENE := preload(_PROJ_SCENE_PATH)

## Travel speed of the [PiercingProjectile] fired when cast.
var projectile_speed: int = 6
## Base damage of the [PiercingProjectile] fired when cast.
var base_damage: int = 60
## Radius of the [PiercingProjectile] fired when cast.
var projectile_radius: int = 10
## Knockback applied to [Character]s hit by the [PiercingProjectile].
var projectile_knockback: float = 1000.0

## The amount of time the cäster has to aim before firing the projectile.
var aim_time: float = 0.5
## Timer used to time the aiming.
var aim_timer: Timer
## Amount by which the caster's speed is debuffed on ability cast.
var aim_speed_debuff: int = 250


func _init() -> void:
	super(2.0, "Aims, slowing the user down temporarily,
			and fires a fast piercing projectile.")


func _ready() -> void:
	_create_aim_timer()


func _perform_ability() -> void:
	_apply_speed_debuff()
	aim_timer.start()
	character.show_aim_line()


func _finish_aiming() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var proj := ProjectileFunctions.fire_projectile_from_character(
			_PROJ_SCENE, character, projectile_speed,
			damage, projectile_radius)
	proj.knockback = projectile_knockback
	character.hide_aim_line()
	finished_casting.emit()


func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-aim_speed_debuff, aim_time)
	speed_debuff.apply_to_stat(character.speed)


func _create_aim_timer() -> void:
	aim_timer = Timer.new()
	aim_timer.wait_time = aim_time
	aim_timer.one_shot = true
	aim_timer.timeout.connect(_finish_aiming)
	add_child(aim_timer)
