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
## Amount by which the caster's speed is debuffed on ability cast.
var aim_speed_debuff: int = 50


func _init() -> void:
	var ability_cooldown: float = 1.5
	var ability_cast_time: float = aim_time
	var ability_description := "Aims, slowing the caster down temporarily,\
			 and fires a fast piercing projectile."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var proj := ProjectileFunctions.fire_projectile_from_character(
			_PROJ_SCENE, character, projectile_speed,
			damage, projectile_radius)
	proj.knockback = projectile_knockback
	character.hide_aim_line()
	finished_casting.emit()


func _handle_casting() -> void:
	_apply_speed_debuff()
	character.show_aim_line()


func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-aim_speed_debuff, 0)
	speed_debuff.apply_to_stat(character.speed)
	was_interrupted.connect(speed_debuff.end)
	finished_casting.connect(speed_debuff.end)


func _reset_ability() -> void:
	character.hide_aim_line()
