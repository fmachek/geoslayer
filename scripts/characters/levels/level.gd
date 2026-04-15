class_name Level
extends Node
## Represents a [Character]'s level.
##
## When [member current_xp] reaches [member required_xp],
## [member current_level] increases by one (the [Character] levels up).
## [member current_xp] then resets back to 0.

## Emitted when [member current_level] changes.
signal level_changed(new_level: int)
## Emitted when [member current_xp] changes.
signal current_xp_changed(new_xp: int)
## Emitted when [member required_xp] changes.
signal required_xp_changed(new_xp: int)

## Amount of XP required to level up.
@export var required_xp: int = 100: set = set_required_xp
## Current XP.
@export var current_xp: int = 0: set = set_current_xp
## Current level, increases when [member current_xp]
## reaches [member required_xp].
@export var current_level: int = 1: set = set_current_xp


## Adds [param xp] to [member current_xp]. Also handles cases
## where [param xp] is great enough to cause [member current_xp] to reach
## [member required_xp] more than once.
func add_xp(xp: int) -> void:
	while (current_xp + xp) >= required_xp:
		xp -= (required_xp - current_xp)
		level_up()
	current_xp += xp


## Resets [member current_xp] to 0 and increases
## [member current_level] by 1. Also multiplies
## [member required_xp] by 1.05 to require more XP for higher levels.
func level_up() -> void:
	current_xp = 0
	current_level += 1
	required_xp *= 1.05 # Required XP increases with each new level


## Sets [member required_xp] to [param value].
## [param value] must be greater than 0.
func set_required_xp(value: int) -> void:
	if value > 0:
		required_xp = value
		required_xp_changed.emit(value)


## Sets [member current_xp] to [param value].
## [param value] must be greater than or equal to 0.
func set_current_xp(value: int) -> void:
	if value >= 0:
		current_xp = value
		current_xp_changed.emit(value)


## Sets [member current_level] to [param value].
## [param value] must be greater than 0.
func set_current_level(value: int) -> void:
	if value > 0:
		current_level = value
		level_changed.emit(value)
