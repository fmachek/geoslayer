class_name Cannonball
extends Ability
## Represents the Cannonball ability which fires a large, slow
## and high-damage projectile and applies a short speed debuff to
## the caster. The projectile also applies a long knockback.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile] fired when cast.
var projectile_speed: int = 2
## Base damage of the [Projectile] fired when cast.
var base_damage: int = 40
## Radius of the [Projectile] fired when cast.
var projectile_radius: int = 20
## Knockback applied to [Character]s hit by the [Projectile].
var projectile_knockback: float = 1500.0

## The amount by which the caster's speed is debuffed on cast.
var speed_debuff: int = 100
## The duration of the speed debuff on cast in seconds.
var speed_debuff_duration: float = 0.5


func _init() -> void:
	super._init(1, "Shoots a large projectile and applies
			a short speed debuff and long knockback to the caster.")


## Fires a large, slow and high-damage [Projectile].
## Applies a speed debuff to the caster.
func _perform_ability() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var proj := ProjectileFunctions.fire_projectile_from_character(_PROJ_SCENE,
			character, projectile_speed, damage, projectile_radius)
	proj.knockback = projectile_knockback
	_add_speed_debuff()
	finished_casting.emit()


## Applies a short speed debuff to the caster.
func _add_speed_debuff() -> void:
	var debuff := Buff.new(-speed_debuff, speed_debuff_duration)
	debuff.apply_to_stat(character.speed)
