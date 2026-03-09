class_name Pierce
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/piercing_projectile.tscn")
var projectile_speed: int = 6 # Pierce projectiles are fast
var base_damage: int = 50 # Pierce projectiles should deal a lot of damage
var projectile_radius: int = 10
# The amount of time the character has to aim.
var aim_time: float = 1.0
# The aim timer is used to time the aiming - the player "aims" for a bit
# after casting Pierce.
var aim_timer: Timer
# When aiming, a speed debuff is applied to the caster.
var aim_speed_debuff: int = 250

func _ready() -> void:
	aim_timer = Timer.new()
	aim_timer.wait_time = aim_time
	aim_timer.one_shot = true
	aim_timer.timeout.connect(finish_aiming)
	add_child(aim_timer)

func _init():
	super._init()
	ability_name = "Pierce"
	cooldown = 4 # This ability has a long cooldown
	texture = load("res://assets/sprites/pierce.png")
	description = "Aims, slowing the user down temporarily, and fires a fast piercing projectile."

# A speed debuff is applied to the caster and the aim timer starts.
func perform_ability():
	var speed_debuff: Buff = Buff.new(-aim_speed_debuff, aim_time)
	character.speed.add_buff(speed_debuff)
	speed_debuff.apply(character.speed)
	aim_timer.start()
	character.show_aim_line()

# Aiming finishes and the piercing projectile is fired.
func finish_aiming() -> void:
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(projectile_scene, character, projectile_speed, damage, projectile_radius)
	character.hide_aim_line()
	finished_casting.emit()
