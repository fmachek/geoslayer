class_name Cannonball
extends Ability

var projectile_scene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 2
var damage: int = 40
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
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	var direction = (target_pos - player_pos).normalized()
	var projectile: Projectile = projectile_scene.instantiate()
	var projectile_fill_color: Color = character.draw_color
	var projectile_outline_color: Color = character.outline_color
	projectile.set_properties(projectile_fill_color, projectile_outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
	character.get_parent().add_child(projectile)
	add_speed_debuff()
	finished_casting.emit()

func add_speed_debuff():
	var debuff = Buff.new(-speed_debuff, speed_debuff_duration)
	character.speed.add_buff(debuff)
	debuff.apply(character.speed)
