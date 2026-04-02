class_name Shred
extends Ability
## Represents the Shred ability, which fires multiple short-lived
## [FalloffProjectile]s in a cone. It applies a speed and armor buff
## to the caster on hit.

const _PROJ_SCENE := preload(
		"res://scenes/objects/projectiles/falloff_projectile.tscn")

## Travel speed of the [FalloffProjectile]s fired when cast.
var projectile_speed: int = 4
## Base damage of the [FalloffProjectile]s fired when cast.
var base_damage: int = 20
## Radius of the [FalloffProjectile]s fired when cast.
var projectile_radius: int = 6
## Time until the [FalloffProjectile] disappears.
var projectile_free_time: float = 0.25

## Amount of [FalloffProjectile]s fired on cast.
var projectile_amount: int = 4
## Angle of the cone spread in radians.
var spread_angle: float = deg_to_rad(20)
## Speed buff amount applied to [member character].
var speed_buff: int = 30
## Duration of speed buff applied to [member character].
var speed_buff_duration: float = 1.0
## Armor buff amount applied to [member character].
var armor_buff: int = 20
## Duration of armor buff applied to [member character].
var armor_buff_duration: float = 1.0


func _init() -> void:
	var desc := ("Fires %d projectiles in a close range cone. " + \
	"The projectiles deal more damage up close. Each hit applies " + \
	" an armor and speed buff to the caster.") % projectile_amount
	super(1.0, "res://assets/sprites/shred.png", desc)


func _perform_ability() -> void:
	var projectiles: Array[Projectile] = ProjectileFunctions.fire_projectile_cone(
			_PROJ_SCENE, projectile_amount, spread_angle,
			character, base_damage, projectile_speed, projectile_radius)
	for proj in projectiles:
		proj.free_time = projectile_free_time
		proj.hit_character.connect(_apply_speed_buff.unbind(1))
		proj.hit_character.connect(_apply_armor_buff.unbind(1))
	finished_casting.emit()


func _apply_speed_buff() -> void:
	var buff := Buff.new(speed_buff, speed_buff_duration)
	buff.apply_to_stat(character.speed)


func _apply_armor_buff() -> void:
	var buff := Buff.new(armor_buff, armor_buff_duration)
	buff.apply_to_stat(character.armor)
