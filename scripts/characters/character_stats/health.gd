class_name Health
extends CharacterStat

## Represents a character's HP. Contains regeneration logic.

## Timer used to time regeneration ticks.
var regen_tick_timer: Timer
## Timer used to time the regeneration cooldown.
var regen_start_timer: Timer
## Heal amount each tick.
@export var regen_amount: int = 2

func _ready() -> void:
	super()
	regen_tick_timer = $RegenTickTimer
	regen_start_timer = $RegenStartTimer

## Reacts to [member Health.current_value] changes. If damage was taken,
## regeneration is interrupted.
func _on_current_value_changed(old_value: int, new_value: int) -> void:
	if old_value > new_value: # Damage was taken
		regen_tick_timer.stop() # Stop healing
		regen_start_timer.start() # Start cooldown for healing

## When [member Health.regen_start_timer] times out, [member Health.regen_tick_timer] starts.
func _on_regen_start_timer_timeout() -> void:
	regen_tick_timer.start()

## When [member Health.regen_tick_timer] times out, [member Health.regen_amount] is
## added to [member Health.current_value].[br]
## If [member Health.current_value] has reached [member Health.max_value_after_buffs],
## [member Health.regen_tick_timer] stops (regeneration stops).
func _on_regen_tick_timer_timeout() -> void:
	add_value(regen_amount)
	if current_value == max_value_after_buffs:
		regen_tick_timer.stop()

## Reacts to [member Health.max_value_after_buffs] changes.
## If the maximum HP was buffed, regeneration starts immediately
## ([member Health.regen_tick_timer] starts), so that [member Health.current_value]
## can catch up to [member Health.max_value_after_buffs].
func _on_max_value_after_buffs_changed(old_value: int, new_value: int) -> void:
	if new_value > old_value: # Start regeneration if max HP was buffed
		regen_start_timer.stop()
		regen_tick_timer.start()
