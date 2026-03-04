class_name Cannonball
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 2
var base_damage: int = 40
var projectile_radius: int = 20
var speed_debuff := 100
var speed_debuff_duration: float = 0.5

func _init():
	super._init()
	ability_name = "Cannonball"
	cooldown = 1
	texture = load("res://assets/sprites/cannonball.png")
	description = "Shoots a large projectile and applies a short speed debuff to the caster."

func perform_ability():
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(character, projectile_speed, damage, projectile_radius)
	add_speed_debuff()
	finished_casting.emit()

func add_speed_debuff():
	var debuff = Buff.new(-speed_debuff, speed_debuff_duration)
	character.speed.add_buff(debuff)
	debuff.apply(character.speed)
