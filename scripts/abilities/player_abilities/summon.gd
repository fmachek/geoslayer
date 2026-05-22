class_name Summon
extends Ability
## Represents the Summon ability which summons minions around the
## caster's target position.
##
## This class uses [RayCast2D] to ensure that minions aren't spawned
## behind walls.

## Emitted when [member minion_amount] changes.
signal minion_amount_changed(amount: int)

#region constants
const _MINION_SCENE := preload(
		"res://scenes/characters/minions/shooter_minion.tscn")
const _POS_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_position_particles.tscn")
const _CAST_PART_SCENE := preload(
		"res://scenes/particle_effects/teleport_cast_particles.tscn")
#endregion

#region regular variables
## Amount of minions spawned.
var minion_amount: int = 5: set = set_minion_amount
## Minions' distance from the cast target position.
var minion_distance: float = 100.0

var _minion_spawn_pos: Vector2
var _speed_debuff: int = 50
#endregion


func _init() -> void:
	var ability_cooldown: float = 5.0
	var ability_cast_time: float = 0.5
	var ability_description: String = "Summons %d minions." % minion_amount
	super(ability_cooldown, ability_cast_time, ability_description)
	minion_amount_changed.connect(_update_description)


func _perform_ability() -> void:
	if _minion_spawn_pos:
		_spawn_minions(_minion_spawn_pos)
		_spawn_cast_particles()
	finished_casting.emit()


func _handle_casting() -> void:
	var target_pos: Vector2 = character.target_pos
	_minion_spawn_pos = character.get_raycast_collision(target_pos)
	_spawn_pos_particles()
	_apply_speed_debuff()


func _apply_speed_debuff() -> void:
	var speed_debuff: Buff = Buff.new(-_speed_debuff, 0)
	speed_debuff.apply_to_stat(character.speed)
	was_interrupted.connect(speed_debuff.end)
	finished_casting.connect(speed_debuff.end)


# Spawns minions around the caster's target position. Uses
# RayCast2D to ensure that the minions aren't spawned behind walls.
func _spawn_minions(pos: Vector2) -> void:
	var raycast := RayCast2D.new()
	raycast.hit_from_inside = true
	character.get_parent().add_child(raycast)
	raycast.global_position = pos
	
	var angle: float = 0.0
	for i in range(minion_amount):
		var dir_to_angle: Vector2 = Vector2.from_angle(angle)
		var target_pos: Vector2 = raycast.global_position + dir_to_angle * minion_distance
		_spawn_minion(_get_raycast_collision(raycast, target_pos))
		angle += TAU / minion_amount


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


## Sets [member minion_amount] to [param amount].
## [param amount] must be greater than 0.
func set_minion_amount(amount: int) -> void:
	if amount < 1:
		return
	minion_amount = amount
	minion_amount_changed.emit(amount)


func _update_description(minions: int) -> void:
	self.description = "Summons %d minions." % minions
