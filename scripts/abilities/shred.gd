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
	_fire_projectile_cone(projectile_amount, spread_angle)
	finished_casting.emit()


func _fire_projectile_cone(amount: int, spread: float) -> void:
	var target_pos: Vector2 = character.target_pos
	var target_dir: Vector2 = character.global_position.direction_to(target_pos)
	var target_angle: float = target_dir.angle()
	
	var start_angle: float = target_angle - spread / 2
	for i in range(amount):
		var angle: float = start_angle + i * (spread / (amount - 1))
		_fire_projectile(angle)


func _fire_projectile(angle: float) -> void:
	var direction = Vector2.from_angle(angle)
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var projectile_properties := ProjectileProperties.new(
			character.draw_color, character.outline_color,
			direction, projectile_speed, character, damage,
			projectile_radius, character.global_position)
	var proj := ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
	proj.free_time = projectile_free_time
	proj.hit_character.connect(_apply_speed_buff.unbind(1))
	proj.hit_character.connect(_apply_armor_buff.unbind(1))


func _apply_speed_buff() -> void:
	var buff := Buff.new(speed_buff, speed_buff_duration)
	buff.apply_to_stat(character.speed)


func _apply_armor_buff() -> void:
	var buff := Buff.new(armor_buff, armor_buff_duration)
	buff.apply_to_stat(character.armor)
