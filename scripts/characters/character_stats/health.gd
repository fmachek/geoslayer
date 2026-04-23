class_name Health
extends CharacterStat
## Represents a character's HP. Contains regeneration logic.

## Heal amount each tick.
var regen_amount: int

@onready var _regen_tick_timer: Timer = $RegenTickTimer
@onready var _regen_start_timer: Timer = $RegenStartTimer


# Reacts to current_value changes. If damage was taken,
# regeneration is interrupted.
func _on_current_value_changed(old_value: int, new_value: int) -> void:
	if old_value > new_value: # Damage was taken
		if _regen_tick_timer:
			_regen_tick_timer.stop() # Stop healing
		if _regen_start_timer:
			_regen_start_timer.start() # Start cooldown for healing


# Regeneration starts when regen_start_timer times out.
func _on_regen_start_timer_timeout() -> void:
	_regen_tick_timer.start()


# Handles regeneration ticks.
func _on_regen_tick_timer_timeout() -> void:
	add_value(regen_amount)
	if current_value == max_value_after_buffs:
		_regen_tick_timer.stop()


# Reacts to max_value_after_buffs changes.
# If the maximum HP was buffed, regeneration starts immediately,
# so that current_value can catch up to max_value_after_buffs.
func _on_max_value_after_buffs_changed(old_value: int, new_value: int) -> void:
	if new_value > old_value: # Start regeneration if max HP was buffed
		if is_instance_valid(_regen_start_timer):
			_regen_start_timer.stop()
		if is_instance_valid(_regen_tick_timer):
			_regen_tick_timer.start()


func _update_regen_amount(max_health: int) -> void:
	regen_amount = max_health / 50
