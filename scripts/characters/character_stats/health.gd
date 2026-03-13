# Represents a character's HP. Contains regeneration logic.

class_name Health
extends CharacterStat

var regen_tick_timer: Timer # Timer for regeneration ticks
var regen_start_timer: Timer # Timer for regeneration cooldown

@export var regen_amount: int = 2 # Heal amount each tick

func _ready() -> void:
	super()
	regen_tick_timer = $RegenTickTimer
	regen_start_timer = $RegenStartTimer

# Handles current HP changes - if damage was taken, healing is interrupted.
func _on_current_value_changed(old_value: int, new_value: int) -> void:
	if old_value > new_value: # Damage was taken
		regen_tick_timer.stop() # Stop healing
		regen_start_timer.start() # Start cooldown for healing

# When the regeneration cooldown timer times out, the tick timer starts.
func _on_regen_start_timer_timeout() -> void:
	regen_tick_timer.start()

# When the regeneration tick timer times out, the heal amount is added to the current value.
# If the player hits max health, the regeneration tick timer stops.
func _on_regen_tick_timer_timeout() -> void:
	add_value(regen_amount)
	if current_value == max_value_after_buffs:
		regen_tick_timer.stop()

# Handles max HP after buffs changes. If the max HP was buffed, the regeneration
# starts immediately, so that the current HP can catch up to the max HP.
func _on_max_value_after_buffs_changed(old_value: int, new_value: int) -> void:
	if new_value > old_value: # Start 
		regen_start_timer.stop()
		regen_tick_timer.start()
