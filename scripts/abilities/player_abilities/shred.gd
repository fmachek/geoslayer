class_name Shred
extends Ability
## Represents the Shred ability, which fires multiple short-lived
## [FalloffProjectile]s in a cone. It applies a speed and armor buff
## to the caster on hit.

const _PROJ_SCENE := preload(
		"res://scenes/objects/projectiles/falloff_projectile.tscn")
const _BUFF_PARTICLES_SCENE := preload(
	"res://scenes/particle_effects/shred/shred_buff_particles.tscn"
)

## Travel speed of the [FalloffProjectile]s fired when cast.
var projectile_speed: int = 4
## Base damage of the [FalloffProjectile]s fired when cast.
var base_damage: int = 20
## Radius of the [FalloffProjectile]s fired when cast.
var projectile_radius: int = 6
## Time until the [FalloffProjectile] disappears.
var projectile_free_time: float = 0.25
## Knockback applied by the [FalloffProjectile]s.
var projectile_knockback: float = 100.0

## Amount of [FalloffProjectile]s fired on cast.
var projectile_amount: int = 4
## Angle of the cone spread in radians.
var spread_angle: float = deg_to_rad(20)
## Speed buff amount applied to [member character] per projectile.
var speed_buff: int = 10
## Duration of speed buff applied to [member character].
var speed_buff_duration: float = 1.0
## Base buff amount applied to [member character] per projectile.
var base_armor_buff: int = 10
## Multiplier of the armor buff, set when the ability is performed.
var armor_buff_multiplier: float = 1.0
## Duration of armor buff applied to [member character].
var armor_buff_duration: float = 1.0


func _init() -> void:
	var ability_cooldown: float = 1.0
	var ability_cast_time: float = 0.0
	var ability_cast_range: float = 200.0
	var ability_description := ("Fires %d projectiles in a close range cone. " + \
	"The projectiles deal more damage up close. Each hit applies" + \
	" an armor and speed buff to the caster.") % projectile_amount
	super(ability_cooldown, ability_cast_time, ability_description, ability_cast_range)


func _perform_ability() -> void:
	_update_armor_buff_multiplier()
	var projectiles: Array[Projectile] = ProjectileFunctions.fire_projectile_cone(
			_PROJ_SCENE, projectile_amount, spread_angle,
			character, base_damage, projectile_speed, projectile_radius)
	for proj in projectiles:
		proj.free_time = projectile_free_time
		proj.knockback = projectile_knockback
		proj.hit_character.connect(_apply_speed_buff.unbind(1))
		proj.hit_character.connect(_apply_armor_buff.unbind(1))
		proj.hit_character.connect(_emit_buff_particles.unbind(1))
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _apply_speed_buff() -> void:
	var buff := Buff.new(speed_buff, speed_buff_duration)
	buff.apply_to_stat(character.speed)


func _apply_armor_buff() -> void:
	var armor_buff: int = base_armor_buff * armor_buff_multiplier
	var buff := Buff.new(armor_buff, armor_buff_duration)
	buff.apply_to_stat(character.armor)


func _update_armor_buff_multiplier() -> void:
	var caster_level: int = character.level.current_level
	# Armor scales every 10 levels
	armor_buff_multiplier = 1 + caster_level / 10


func _emit_buff_particles() -> void:
	var particles: ShredBuffParticles = _BUFF_PARTICLES_SCENE.instantiate()
	particles.speed_particle_color = character.draw_color.lightened(0.3)
	particles.shield_particle_color = character.draw_color.lightened(0.2)
	character.add_child(particles)
	particles.global_position = character.global_position
