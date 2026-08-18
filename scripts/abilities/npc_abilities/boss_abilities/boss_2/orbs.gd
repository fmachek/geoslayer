class_name Orbs
extends Ability

const _ORB_SCENE := preload(
	"res://scenes/characters/enemies/bosses/boss_2/explosive_orb.tscn"
)
const _ORB_DISTANCE: float = 500.0


func _init() -> void:
	var cd: float = 45.0
	var ability_cast_time: float = 0.0
	var desc: String = "Spawns 4 orbs which detonate after a certain amount of time."
	super(cd, ability_cast_time, desc)


func _perform_ability() -> void:
	var vectors: Array[Vector2] = [
		Vector2(_ORB_DISTANCE, 0),
		Vector2(-_ORB_DISTANCE, 0),
		Vector2(0, _ORB_DISTANCE),
		Vector2(0, -_ORB_DISTANCE)
	]
	for vector: Vector2 in vectors:
		var pos: Vector2 = character.global_position + vector
		var col_pos: Vector2 = character.get_raycast_collision(pos)
		var direction: Vector2 = character.global_position.direction_to(col_pos)
		var final_pos: Vector2 = col_pos - direction * 50
		call_deferred("_spawn_orb", character.get_raycast_collision(final_pos))
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _spawn_orb(pos: Vector2) -> void:
	var parent = character.get_parent()
	if is_instance_valid(parent):
		var orb: ExplosiveOrb = _ORB_SCENE.instantiate()
		parent.add_child(orb)
		orb.global_position = pos
