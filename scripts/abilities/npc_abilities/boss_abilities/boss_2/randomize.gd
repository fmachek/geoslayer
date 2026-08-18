class_name Randomize
extends Ability

var tile_damage: int = 30


func _init() -> void:
	super(5.0, 0.0, "Triggers random boss attack tiles.")


func _perform_ability() -> void:
	if character is not Boss2: # Only usable by boss 2
		return
	var tile_manager: AttackTileManager = character.attack_tile_manager
	if not is_instance_valid(tile_manager):
		return
	var damage: int = float(character.damage.max_value_after_buffs) / 100 \
			* float(tile_damage)
	tile_manager.trigger_random_attack(damage)
	finished_casting.emit()


func _handle_casting() -> void:
	pass
