class_name UserStat
extends RefCounted
## Represents a permanent stat upgrade which is used to increase
## the player's in-game stat when spawning.

## Emitted when [member stat_value] changes.
signal value_changed(new_value: int)

## Name of the stat.
var stat_name: String
## Value of the stat.
var stat_value: int:
	set(value):
		stat_value = value
		value_changed.emit(value)


## Sets [member stat_name] and [member stat_value].
func _init(name: String, value: int) -> void:
	self.stat_name = name
	self.stat_value = value
