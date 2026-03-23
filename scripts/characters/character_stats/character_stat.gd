class_name CharacterStat
extends Node

## Represents a character stat such as HP, speed, damage etc.
##
## This class can work with buffs and debuffs and handles maximum and current values.
##
## Every time a [Buff] is added or removed, [member CharacterStat.total_buff] is calculated
## and with that [member CharacterStat.max_value_after_buffs] is changed.
## [member CharacterStat.current_value] cannot exceed [member CharacterStat.max_value_after_buffs].

#region signals
## Emitted when the max value changes. Passes the old and new values as arguments.
signal max_value_changed(old_value: int, new_value: int)
## Emitted when the current value changes. Passes the old and new values as arguments.
signal current_value_changed(old_value: int, new_value: int)
## Emitted when the maximum value after buffs changes. Passes the old and
## new values as arguments.
signal max_value_after_buffs_changed(old_value: int, new_value: int)
## Emitted when the total buff value changes. Passes the old and new values as arguments.
signal total_buff_changed(old_value: int, new_value: int)
## Emitted when a new [Buff] is applied to this [CharacterStat].
signal added_buff(buff: Buff)
#endregion

#region @export variables
## Name of the stat, for example "Health".
@export var stat_name: String
## Default maximum value before any buffs are applied.
@export var max_value: int: set = _change_max_value
## The current value. Used for stats which have a maximum and current value such as HP.
@export var current_value: int: set = _change_current_value
## Value by which the stat increases when a perk point is applied.
@export var perk_point_increase: int = 5
#endregion

## The modified maximum value after buffs and debuffs are applied. It is the main value
## which is usually used. For example, when speed is used for movement,
##  this value is what is really being used, not current_value.
var max_value_after_buffs: int: set = _change_max_value_after_buffs
## Sum of the values of all buffs and debuffs.
var total_buff: int = 0
## Node containing all the [Buff] nodes modifying this stat.
var buffs: Node

# Important note:
# Max value after buffs is the value that is usually used for various calculations.
# For example, when speed is used for movement, what is really used is this value.
# While all of these 3 values are used for Max HP for example, for other stats
# such as speed, 'current_value' goes unused and is technically redundant.
# I might change the stats system in the future if this becomes annoying.


# Creates the buffs node and sets max_value_after_buffs to its default value.
func _ready() -> void:
	buffs = Node.new()
	buffs.name = "Buffs"
	add_child(buffs)
	max_value_after_buffs = max_value


## Adds a new [Buff] to [member CharacterStat.buffs], calculates
## [member CharacterStat.total_buff] and applies it.
func add_buff(buff: Buff) -> void:
	buffs.add_child(buff)
	added_buff.emit(buff)
	_calculate_total_buff()


## Removes a [Buff] from [member CharacterStat.buffs], calculates
## [member CharacterStat.total_buff] and applies it.
func remove_buff(buff: Buff) -> void:
	buffs.remove_child(buff)
	buff.queue_free()
	_calculate_total_buff()


## Calculates [member CharacterStat.total_buff] and applies it.
func _calculate_total_buff() -> void:
	var buff_sum: int = 0
	if is_instance_valid(buffs):
		for buff: Buff in buffs.get_children():
			buff_sum += buff.amount
	_change_total_buff(buff_sum)


## Changes [member CharacterStat.current_value], checks for edge cases such as the new value
## exceeding [member CharacterStat.max_value_after_buffs].[br]
## Emits [member CharacterStat.current_value_changed].
func _change_current_value(value: int) -> void:
	if current_value == value:
		return
	if value > max_value_after_buffs:
		value = max_value_after_buffs
	if value < 0:
		value = 0
	var old_value: int = current_value
	current_value = value
	current_value_changed.emit(old_value, current_value)


## Changes [member CharacterStat.max_value] and recalculates [member CharacterStat.total_buff].[br]
## Emits [member CharacterStat.max_value_changed].
func _change_max_value(value: int) -> void:
	if max_value == value:
		return
	var old_value: int = max_value
	max_value = value
	max_value_changed.emit(old_value, max_value)
	_calculate_total_buff()


## Changes [member CharacterStat.max_value_after_buffs]. Checks for edge cases such as
## the new value being negative, which can happen after applying debuffs.[br]
## Also checks if [member CharacterStat.current_value] exceeds the new
## [member CharacterStat.max_value_after_buffs].[br]
## Emits [member CharacterStat.max_value_after_buffs_changed].
func _change_max_value_after_buffs(value: int) -> void:
	if value < 0:
		value = 0
	if max_value_after_buffs == value:
		return
	var old_value: int = max_value_after_buffs
	max_value_after_buffs = value
	max_value_after_buffs_changed.emit(old_value, max_value_after_buffs)
	
	if current_value > max_value_after_buffs:
		current_value = max_value_after_buffs


## Changes [member CharacterStat.total_buff] and
## changes [member CharacterStat.max_value_after_buffs].[br]
## Emits [member CharacterStat.total_buff_changed].
func _change_total_buff(value: int) -> void:
	if total_buff != value:
		var old_value = total_buff
		total_buff = value
		total_buff_changed.emit(old_value, total_buff)
	
	max_value_after_buffs = max_value + total_buff


## Adds a given [param amount] to [member CharacterStat.current_value].
func add_value(value: int) -> void:
	current_value += value


## Increases [member CharacterStat.max_value] by
## [member CharacterStat.perk_point_increase].
func apply_perk_point() -> void:
	max_value += perk_point_increase
