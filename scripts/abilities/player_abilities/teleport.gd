class_name Teleport
extends Ability
## Represents the Teleport ability which teleports the caster to
## their target's position ([member Character.target_pos]).
##
## The ability takes some time to cast and only teleports the caster
## when it finishes casting. [RayCast2D] is used to check for
## line of sight. That prevents teleporting behind a wall for example.

const _POS_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_position_particles.tscn")
const _CAST_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_cast_particles.tscn")

var _teleport_pos: Vector2


func _init() -> void:
	var ability_cooldown: float = 3.0
	var ability_cast_time: float = 0.4
	var ability_description := "Teleports the caster."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	_teleport_caster(_teleport_pos)
	finished_casting.emit()


func _handle_casting() -> void:
	var target_pos: Vector2 = character.target_pos
	_teleport_pos = character.get_raycast_collision(target_pos)
	_apply_speed_debuff()
	_spawn_teleport_position_particles(_teleport_pos)


func _teleport_caster(pos: Vector2) -> void:
	_spawn_teleport_cast_particles()
	character.global_position = pos


func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-50000, 0)
	speed_debuff.apply_to_stat(character.speed)
	was_interrupted.connect(speed_debuff.end)
	finished_casting.connect(speed_debuff.end)


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
