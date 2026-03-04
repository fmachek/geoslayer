class_name Shoot
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 3
var base_damage: int = 20
var projectile_radius: int = 10

func _init():
	super._init()
	ability_name = "Shoot"
	cooldown = 0.5
	texture = load("res://assets/sprites/shoot.png")
	description = "Shoots a projectile."

func perform_ability():
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(character, projectile_speed, damage, projectile_radius)
	finished_casting.emit()
