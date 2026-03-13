## Represents the Cannonball ability which fires a large, slow and high-damage projectile and
## applies a short speed debuff to the caster.
class_name Cannonball
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 2
var base_damage: int = 40
var projectile_radius: int = 20

## The amount by which the Character's speed is debuffed on Ability cast.
var speed_debuff := 100
## The duration of the speed debuff on Ability cast.
var speed_debuff_duration: float = 0.5

func _init() -> void:
	super._init(1, "res://assets/sprites/cannonball.png", "Shoots a large projectile and applies a short speed debuff to the caster.")

## Fires a large, slow and high-damage projectile. Applies a speed debuff to the caster.
func perform_ability() -> void:
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(projectile_scene, character, projectile_speed, damage, projectile_radius)
	add_speed_debuff()
	finished_casting.emit()

## Applies a short speed debuff to the caster.
func add_speed_debuff() -> void:
	var debuff = Buff.new(-speed_debuff, speed_debuff_duration)
	character.speed.add_buff(debuff)
	debuff.apply(character.speed)
