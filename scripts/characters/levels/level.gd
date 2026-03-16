class_name Level
extends Node

## Represents a [Character]'s level.
##
## When [member Level.current_xp] reaches [member Level.required_xp],
## [member Lebel.current_level] increases by one (the [Character] levels up).
## [member Level.current_xp] then resets back to 0.

## Amount of XP required to level up.
@export var required_xp: int = 100
@export var current_xp: int = 0 ## Current XP.
## Current level, increases when [member Level.current_xp] reaches [member Level.required_xp].
@export var current_level: int = 1

## Emitted when [member Level.current_level] changes.
signal level_changed(new_level: int)
## Emitted when [member Level.current_xp] changes.
signal current_xp_changed(new_xp: int)
## Emitted when [member Level.required_xp] changes.
signal required_xp_changed(new_xp: int)

## Adds [param xp] to [member Level.current_xp]. Also handles cases
## where [param xp] is great enough to cause [member Level.current_xp] to reach
## [member Level.required_xp] more than once.
func add_xp(xp: int) -> void:
	while (current_xp + xp) >= required_xp:
		xp -= (required_xp - current_xp)
		level_up()
	current_xp += xp
	current_xp_changed.emit(current_xp)

## Resets [member Level.current_xp] to 0 and increases [member Level.current_level] by 1.
## Also multiplies [member Level.required_xp] by 1.3 to require more XP for higher levels.
func level_up() -> void:
	current_xp = 0
	current_xp_changed.emit(current_xp)
	
	current_level += 1
	level_changed.emit(current_level)
	
	required_xp *= 1.3 # Required XP increases with each new level
	required_xp_changed.emit(required_xp)
