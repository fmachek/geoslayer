## Represents the Pierce ability, which fires a piercing, high-damage projectile with a unique look.
## The caster needs to aim for a bit before firing the projectile.
class_name Pierce
extends Ability

# This scene is different from the default Projectile scene used in abilities such as Shoot.
var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/piercing_projectile.tscn")
var projectile_speed: int = 6 # Pierce projectiles are fast
var base_damage: int = 50 # Pierce projectiles should deal a lot of damage
var projectile_radius: int = 10

## The amount of time the character has to aim before firing the projectile.
var aim_time: float = 1.0
## Timer used to time the aiming.
var aim_timer: Timer
## Amount by which the caster's speed is debuffed on ability cast.
var aim_speed_debuff: int = 250

## Creates the aim timer when entering the scene tree.
func _ready() -> void:
	_create_aim_timer()

## Creates the aim timer and adds it as a child of the ability.
func _create_aim_timer() -> void:
	aim_timer = Timer.new()
	aim_timer.wait_time = aim_time
	aim_timer.one_shot = true
	aim_timer.timeout.connect(_finish_aiming)
	add_child(aim_timer)

func _init()-> void:
	super._init(4, "res://assets/sprites/pierce.png", "Aims, slowing the user down temporarily, and fires a fast piercing projectile.")

## Applies a speed debuff to the caster and starts the aim timer.
## Also shows the aim line to dislay where the caster is aiming.
func perform_ability() -> void:
	_apply_speed_debuff()
	aim_timer.start()
	character.show_aim_line()

## Applies a speed debuff to the caster. It lasts as long as the aiming.
func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-aim_speed_debuff, aim_time)
	speed_debuff.apply_to_stat(character.speed)

## Aiming finishes and the piercing projectile is fired.
## The caster's aim line is hidden.
func _finish_aiming() -> void:
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	ProjectileFunctions.fire_projectile_from_character(projectile_scene, character, projectile_speed, damage, projectile_radius)
	character.hide_aim_line()
	finished_casting.emit()
