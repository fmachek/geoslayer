class_name AreaHeal
extends InstantArea
## Represents a circle which instantly heals [Character]s standing inside it.

## Amount for which [Character]s are healed.
var heal_amount: int = 10


func _perform(body: Node2D) -> void:
	if body is Character:
		body.heal(heal_amount)


func _update_area_mask(area_source: Node2D) -> void:
	CollisionMaskFunctions.set_friendly_area_collision_mask(_area, area_source)
