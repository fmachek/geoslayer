@abstract class_name Enemy
extends CastingCharacter
## Represents an enemy who follows the player or their minions
## around and casts abilities.


# Finds the closest PlayerCharacter or Minion in an array of nodes.
func _get_target_from_bodies(bodies: Array[Node2D]) -> Character:
	var smallest_distance: float = 100000.0
	var chosen_target: Node2D = null
	for body: Node2D in bodies:
		if not (body is PlayerCharacter or body is Minion):
			continue
		if body == target:
			continue
		if not body.is_alive:
			continue
		var distance: float = global_position.distance_to(body.global_position)
		if distance < smallest_distance:
			smallest_distance = distance
			chosen_target = body
	return chosen_target


# Detects a player or minion entering the enemy's range.
func _on_character_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter or body is Minion:
		if target:
			var distance_to_body: float = global_position.distance_to(
					body.global_position)
			var distance_to_target: float = global_position.distance_to(
					target.global_position)
			if distance_to_body < distance_to_target:
				target = body
				cast_random_ability()
		else:
			target = body
			cast_random_ability()


# Detects the target leaving the enemy's range.
# Scans for a new target.
func _on_character_detection_area_body_exited(body: Node2D) -> void:
	if target == body:
		_scan_for_target()
