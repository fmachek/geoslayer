class_name AreaHeal
extends InstantArea
## Represents a circle which instantly heals [Character]s standing inside it.

const _HEAL_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/heal_label.tscn")

## Amount for which [Character]s are healed.
var heal_amount: int = 10


func _perform(body: Node2D) -> void:
	if body is Character:
		body.heal(heal_amount)
		_spawn_heal_label(heal_amount, body.global_position)


func _update_area_mask(source: Node2D) -> void:
	CollisionMaskFunctions.set_friendly_area_collision_mask(_area, source)


func _spawn_heal_label(amount: int, pos: Vector2) -> void:
	var heal_label: DamageLabel = _HEAL_LABEL_SCENE.instantiate()
	get_parent().add_child(heal_label)
	heal_label.load_damage(amount, pos)
	heal_label.play_tween()
