class_name Stations
extends Ability
## Spawns 4 enemy [HealingStation]s which heal the caster.
## This is a boss [Ability] used by [Boss1].

const _STATION_SCENE := preload(
		"res://scenes/characters/enemies/bosses/boss_1/healing_station.tscn")
const _STATION_DISTANCE: float = 500.0


func _init() -> void:
	super._init(45, "res://assets/sprites/placeholder.png",
			"Spawns 4 healing stations which heal the caster.")


func _perform_ability() -> void:
	var vectors: Array[Vector2] = [
		Vector2(_STATION_DISTANCE, 0),
		Vector2(-_STATION_DISTANCE, 0),
		Vector2(0, _STATION_DISTANCE),
		Vector2(0, -_STATION_DISTANCE)
	]
	for vector: Vector2 in vectors:
		var pos: Vector2 = character.global_position + vector
		var col_pos: Vector2 = character.get_raycast_collision(pos)
		var direction: Vector2 = character.global_position.direction_to(col_pos)
		var final_pos: Vector2 = col_pos - direction * 50
		_spawn_station(character.get_raycast_collision(final_pos))
	finished_casting.emit()


func _spawn_station(pos: Vector2) -> void:
	var station: HealingStation = _STATION_SCENE.instantiate()
	station.healing_target = character
	character.get_parent().add_child(station)
	station.global_position = pos
