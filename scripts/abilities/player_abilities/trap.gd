class_name Trap
extends Ability

const MINE_SCENE := preload("res://scenes/objects/mines/mine.tscn")

var base_mine_damage: int = 50
var explosion_radius: float = 200.0
var explosion_knockback: float = 1000.0
var automatic_explosion_time: float = 3.0
var stun_duration: float = 0.75


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_description := "Places a mine which deals damage to and stuns enemies. \
			The mine explodes when it is stepped on or automatically after %d seconds. \
			It can also be exploded by the caster's projectiles." % automatic_explosion_time
	super(ability_cooldown, ability_description)


func _perform_ability() -> void:
	var mine: Mine = MINE_SCENE.instantiate()
	mine.draw_color = character.draw_color
	mine.outline_color = character.outline_color
	mine.spawner = character
	mine.explosion_radius = explosion_radius
	mine.explosion_knockback = explosion_knockback
	mine.automatic_explosion_time = automatic_explosion_time
	mine.stun_duration = stun_duration
	var caster_damage: int = character.damage.max_value_after_buffs
	var mine_damage: int = float(base_mine_damage) * (float(caster_damage) / 100)
	mine.explosion_damage = mine_damage
	mine.global_position = character.global_position
	
	character.get_parent().add_child(mine)
	finished_casting.emit()
