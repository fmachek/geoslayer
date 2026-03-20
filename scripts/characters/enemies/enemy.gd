@abstract class_name Enemy
extends CastingCharacter
## Represents an enemy who follows the player around and casts abilities.


# Detects the player entering the enemy's range.
func _on_character_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		target = body
		cast_random_ability()


# Detects the player leaving the enemy's range.
func _on_character_detection_area_body_exited(body: Node2D) -> void:
	if target == body:
		target = null
