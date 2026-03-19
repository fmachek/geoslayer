class_name Teleport
extends Ability

## Represents the Teleport ability which teleports the caster to
## their target's position ([Character.target_pos]).
##
## The ability takes some time to cast and only teleports the caster
## when it finishes casting. [RayCast2D] is used to check for
## line of sight. That prevents teleporting behind a wall for example.

var _cast_timer: Timer
var _cast_time: float = 0.75
var _teleport_pos: Vector2

const _POS_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_position_particles.tscn")
const _CAST_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_cast_particles.tscn")


func _init() -> void:
	super._init(5, "res://assets/sprites/teleport.png",
			"Teleports the caster to the position they're aiming at.")


func _ready() -> void:
	_create_cast_timer()


func _perform_ability() -> void:
	_start_casting()


func _teleport_caster(pos: Vector2) -> void:
	_spawn_teleport_cast_particles()
	character.global_position = pos


func _create_cast_timer() -> void:
	_cast_timer = Timer.new()
	_cast_timer.wait_time = _cast_time
	_cast_timer.one_shot = true
	_cast_timer.timeout.connect(_finish_casting)
	add_child(_cast_timer)


func _start_casting() -> void:
	var target_pos: Vector2 = character.target_pos
	_teleport_pos = _get_raycast_collision(target_pos)
	_apply_speed_debuff()
	_spawn_teleport_position_particles(_teleport_pos)
	_cast_timer.start()


# Applies a speed debuff to the caster which should
# stop them completely.
func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-50000, _cast_time)
	speed_debuff.apply_to_stat(character.speed)


func _finish_casting() -> void:
	if _teleport_pos:
		_teleport_caster(_teleport_pos)
	finished_casting.emit()


## Checks for raycast collisions between [member Teleport.character]
## and [param global_target_pos]. Returns [param global_target_pos]
## if there were no collisions. Otherwise returns the point at which
## the collision occurred.
func _get_raycast_collision(global_target_pos: Vector2) -> Vector2:
	var raycast: RayCast2D = character.get_node("RayCast2D")
	raycast.target_position = character.to_local(global_target_pos)
	raycast.force_raycast_update()
	var col_point: Vector2 = raycast.get_collision_point()
	if raycast.is_colliding():
		return col_point
	else:
		return global_target_pos


func _spawn_teleport_position_particles(pos: Vector2) -> void:
	if _teleport_pos:
		var particles: TeleportPositionParticles = _POS_PART_SCENE.instantiate()
		particles.connect_to_ability(self)
		particles.global_position = pos
		character.get_parent().add_child(particles)


func _spawn_teleport_cast_particles() -> void:
	var particles: TeleportCastParticles = _CAST_PART_SCENE.instantiate()
	particles.global_position = character.global_position
	character.get_parent().add_child(particles)
	particles.emitting = true
