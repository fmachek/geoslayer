class_name Storm
extends Ability
## Summons a [DamagingZone] which deals damage to enemies standing inside of it
## and slows them down.

const _ZONE_SCENE := preload(
		"res://scenes/objects/zones/damaging_zone.tscn")
const _PARTICLE_SCENE := preload(
		"res://scenes/particle_effects/zones/zone_spawning_particles.tscn")

## Position where the [DamagingZone] is being spawned.
var _zone_pos: Vector2
## Time the ability takes to cast.
var _cast_time: float = 1.0
var _cast_timer: Timer

## Time until the [DamagingZone] disappears, in seconds.
var zone_duration: float = 10.0
## Used to set [member DamagingZone.time_per_tick].
var zone_tick_time: float = 1.0
## Used to set [member DamagingZone.base_damage].
var zone_base_damage: int = 7
## Used to set [member DamagingZone.radius].
var zone_radius: int = 250
## Amount by which the caster's speed is decreased when casting.
var speed_debuff_amount: int = 200


func _init() -> void:
	super._init(12.0, "res://assets/sprites/storm.png",
			"Summons a damaging and slowing storm.")


func _ready() -> void:
	_create_cast_timer()


func _perform_ability() -> void:
	var target_pos: Vector2 = character.target_pos
	_zone_pos = character.get_raycast_collision(target_pos)
	_apply_speed_debuff()
	_spawn_cast_particles()
	_start_casting()


func _start_casting() -> void:
	_cast_timer.start()


# Spawns the zone when the casting finishes.
func _finish_casting() -> void:
	_spawn_zone()
	finished_casting.emit()


# Applies a speed debuff which lasts for the whole cast time.
func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-speed_debuff_amount, _cast_time)
	speed_debuff.apply_to_stat(character.speed)


# Spawns a DamagingZone at _zone_pos and sets its damage etc.
func _spawn_zone() -> void:
	var zone: DamagingZone = _ZONE_SCENE.instantiate()
	zone.caster = character
	zone.radius = zone_radius
	zone.base_damage = zone_base_damage
	zone.time_per_tick = zone_tick_time
	zone.global_position = _zone_pos
	character.get_parent().add_child(zone)


func _create_cast_timer() -> void:
	_cast_timer = Timer.new()
	_cast_timer.wait_time = _cast_time
	_cast_timer.one_shot = true
	_cast_timer.timeout.connect(_finish_casting)
	add_child(_cast_timer)


func _spawn_cast_particles() -> void:
	var particles: ZoneSpawningParticles = _PARTICLE_SCENE.instantiate()
	particles.connect_to_ability(self)
	particles.radius = zone_radius
	particles.global_position = _zone_pos
	character.get_parent().add_child(particles)
