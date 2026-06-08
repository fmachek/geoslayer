class_name Tear
extends Ability

const _PROJ_SCENE := preload(
	"res://scenes/objects/projectiles/piercing_projectile.tscn"
)

var projectile_speed: float = 4.0
var base_damage: int = 12
var projectile_radius: float = 6.0
var projectile_knockback: float = 200.0

var projectile_amount: int = 4
var spread_angle: float = deg_to_rad(30)

var speed_debuff: int = 30
var speed_debuff_duration: float = 0.5


func _init() -> void:
	var ability_cooldown: float = 1.0
	var ability_cast_time: float = 0.0
	var ability_description := "Fires a cone of projectiles which pierce through \
			enemies and slow them down."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	var projectiles := ProjectileFunctions.fire_projectile_cone(
			_PROJ_SCENE, projectile_amount, spread_angle,
			character, base_damage, projectile_speed, projectile_radius)
	for proj in projectiles:
		proj.knockback = projectile_knockback
		proj.hit_character.connect(_apply_speed_debuff)
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _apply_speed_debuff(enemy: Character) -> void:
	var debuff := Buff.new(-speed_debuff, speed_debuff_duration)
	debuff.apply_to_stat(enemy.speed)
