class_name Cannonball
extends Ability
## Represents the Cannonball ability which fires a large, slow
## and high-damage projectile and applies a short speed debuff to
## the caster. The projectile also applies a long knockback.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile] fired when cast.
var projectile_speed: float = 2.5
## Base damage of the [Projectile] fired when cast.
var base_damage: int = 70
## Radius of the [Projectile] fired when cast.
var projectile_radius: int = 20
## Knockback applied to [Character]s hit by the [Projectile].
var projectile_knockback: float = 800.0
## Knockback applied to the caster.
var caster_knockback: float = 500.0


func _init() -> void:
	var ability_cooldown: float = 1.0
	var ability_cast_time: float = 0.0
	var ability_description := "Fires a large projectile and knocks \
			the caster back slightly."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var proj := ProjectileFunctions.fire_projectile_from_character(_PROJ_SCENE,
			character, projectile_speed, damage, projectile_radius)
	proj.knockback = projectile_knockback
	_apply_knockback_to_caster()
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _apply_knockback_to_caster() -> void:
	var direction: Vector2 = (character.target_pos - character.global_position).normalized()
	var knockback: Vector2 = caster_knockback * -direction
	character.apply_knockback(knockback)
