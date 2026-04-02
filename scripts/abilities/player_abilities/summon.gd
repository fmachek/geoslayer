class_name Summon
extends Ability
## Represents the Summon ability which summons minions around the
## caster's target position.
##
## This class uses [RayCast2D] to ensure that minions aren't spawned
## behind walls.

#region constants
const _MINION_SCENE := preload(
		"res://scenes/characters/minions/shooter_minion.tscn")
const _POS_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_position_particles.tscn")
const _CAST_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_cast_particles.tscn")
## Amount of minions spawned.
const _MINION_AMOUNT: int = 5
## Minions' distance from the cast target position.
const _MINION_DISTANCE: float = 60.0
#endregion

#region regular variables
var _cast_timer: Timer
var _cast_time: float = 0.75
var _minion_spawn_pos: Vector2
var _speed_debuff: int = 200
#endregion


func _init() -> void:
	var description: String = "Summons %d minions." % _MINION_AMOUNT
	super._init(8, description)


func _ready() -> void:
	_create_cast_timer()


func _perform_ability() -> void:
	_start_casting()


# Gets the raycast collision point if there is one, spawns
# particles and applies a speed debuff.
func _start_casting() -> void:
	var target_pos: Vector2 = character.target_pos
	_minion_spawn_pos = character.get_raycast_collision(target_pos)
	_spawn_pos_particles()
	_apply_speed_debuff()
	_cast_timer.start()


# Spawns the minions when casting finishes.
func _finish_casting() -> void:
	if _minion_spawn_pos:
		_spawn_minions(_minion_spawn_pos)
		_spawn_cast_particles()
	finished_casting.emit()


# Applies a debuff with a duration equal to the cast time.
func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-_speed_debuff, _cast_time)
	speed_debuff.apply_to_stat(character.speed)


# Spawns minions around the caster's target position. Uses
# RayCast2D to ensure that the minions aren't spawned behind walls.
func _spawn_minions(pos: Vector2) -> void:
	var raycast := RayCast2D.new()
	raycast.hit_from_inside = true
	character.get_parent().add_child(raycast)
	raycast.global_position = pos
	
	var angle: float = 0.0
	for i in range(_MINION_AMOUNT):
		var dir_to_angle: Vector2 = Vector2.from_angle(angle)
		var target_pos: Vector2 = raycast.global_position + dir_to_angle * _MINION_DISTANCE
		_spawn_minion(_get_raycast_collision(raycast, target_pos))
		angle += TAU / _MINION_AMOUNT


# Spawns a single minion at the given position.
func _spawn_minion(pos: Vector2) -> void:
	var minion: Minion = _MINION_SCENE.instantiate()
	minion.spawner = character
	minion.global_position = pos
	character.get_parent().add_child(minion)


func _get_raycast_collision(raycast: RayCast2D, global_target_pos: Vector2) -> Vector2:
	raycast.target_position = raycast.to_local(global_target_pos)
	raycast.force_raycast_update()
	var col_pos: Vector2 = raycast.get_collision_point()
	if raycast.is_colliding():
		return col_pos
	else:
		return global_target_pos


func _create_cast_timer() -> void:
	_cast_timer = Timer.new()
	_cast_timer.wait_time = _cast_time
	_cast_timer.one_shot = true
	_cast_timer.timeout.connect(_finish_casting)
	add_child(_cast_timer)


#region particle spawning
func _spawn_pos_particles() -> void:
	var particles: TeleportPositionParticles = _POS_PART_SCENE.instantiate()
	particles.connect_to_ability(self)
	particles.global_position = _minion_spawn_pos
	character.get_parent().add_child(particles)


func _spawn_cast_particles() -> void:
	var particles: TeleportCastParticles = _CAST_PART_SCENE.instantiate()
	particles.connect_to_ability(self)
	particles.global_position = _minion_spawn_pos
	character.get_parent().add_child(particles)
	particles.emitting = true
#endregion
