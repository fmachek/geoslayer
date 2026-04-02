class_name Reinforcements
extends Ability
## Spawns 4 [Slower]s around the caster. This is a boss [Ability]
## used by [Boss1].

const _SLOWER_SCENE := preload(
		"res://scenes/characters/enemies/bosses/boss_1/slower.tscn")
const _SLOWER_DISTANCE: float = 1000.0


func _init() -> void:
	super._init(30, "Spawns 4 Slowers.")


func _perform_ability() -> void:
	var vectors: Array[Vector2] = [
		Vector2(_SLOWER_DISTANCE, 0),
		Vector2(-_SLOWER_DISTANCE, 0),
		Vector2(0, _SLOWER_DISTANCE),
		Vector2(0, -_SLOWER_DISTANCE)
	]
	for vector: Vector2 in vectors:
		var pos: Vector2 = character.global_position + vector
		var col_pos: Vector2 = character.get_raycast_collision(pos)
		var direction: Vector2 = character.global_position.direction_to(col_pos)
		var final_pos: Vector2 = col_pos - direction * 50
		_spawn_slower(character.get_raycast_collision(final_pos))
	finished_casting.emit()


func _spawn_slower(pos: Vector2) -> void:
	var slower: Slower = _SLOWER_SCENE.instantiate()
	character.get_parent().add_child(slower)
	slower.global_position = pos
