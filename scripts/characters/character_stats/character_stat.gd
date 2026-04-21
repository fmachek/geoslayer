class_name CharacterStat
extends Node
## Represents a character stat such as HP, speed, damage etc.
##
## This class can work with buffs and debuffs and handles maximum and current values.
##
## Every time a [Buff] is added or removed, [member total_buff] is calculated
## and with that [member max_value_after_buffs] is changed.
## [member current_value] cannot exceed [member max_value_after_buffs].

#region signals
## Emitted when [member max_value] changes. Passes the old and new values as arguments.
signal max_value_changed(old_value: int, new_value: int)
## Emitted when [member current_value] changes. Passes the old and new values as arguments.
signal current_value_changed(old_value: int, new_value: int)
## Emitted when [member max_value_after_buffs] changes. Passes the old and
## new values as arguments.
signal max_value_after_buffs_changed(old_value: int, new_value: int)
## Emitted when [member total_buff] changes. Passes the old and new values as arguments.
signal total_buff_changed(old_value: int, new_value: int)
## Emitted when a new [Buff] is applied.
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
## Says whether the stat is percentage based or not.
@export var is_percentage_based: bool = false
#endregion

## The modified maximum value after buffs and debuffs are applied. It is the main value
## which is usually used. For example, when speed is used for movement,
## this value is what is really being used instead of [member current_value].
var max_value_after_buffs: int: set = _change_max_value_after_buffs
## Sum of the values of all buffs and debuffs.
var total_buff: int = 0
## [Node] containing all the [Buff] nodes modifying this stat.
var buffs: Node


# Creates the buffs node and sets max_value_after_buffs to its default value.
func _ready() -> void:
	buffs = Node.new()
	buffs.name = "Buffs"
	add_child(buffs)
	max_value_after_buffs = max_value


## Adds a new [Buff] to [member buffs], calculates
## [member total_buff] and applies it.
func add_buff(buff: Buff) -> void:
	buffs.add_child(buff)
	added_buff.emit(buff)
	_calculate_total_buff()


## Removes a [Buff] from [member buffs], calculates
## [member total_buff] and applies it.
func remove_buff(buff: Buff) -> void:
	buffs.remove_child(buff)
	buff.queue_free()
	_calculate_total_buff()


## Adds a given [param amount] to [member current_value].
func add_value(value: int) -> void:
	current_value += value


## Increases [member max_value] by [member perk_point_increase].
func apply_perk_point() -> void:
	max_value += perk_point_increase


func _calculate_total_buff() -> void:
	var buff_sum: int = 0
	if is_instance_valid(buffs):
		for buff: Buff in buffs.get_children():
			buff_sum += buff.amount
	_change_total_buff(buff_sum)


func _change_current_value(value: int) -> void:
	if current_value == value:
		return
	value = clamp(value, 0, max_value_after_buffs)
	var old_value: int = current_value
	current_value = value
	current_value_changed.emit(old_value, current_value)


func _change_max_value(value: int) -> void:
	if max_value == value:
		return
	var old_value: int = max_value
	max_value = value
	max_value_changed.emit(old_value, max_value)
	_calculate_total_buff()


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


func _change_total_buff(value: int) -> void:
	if total_buff != value:
		var old_value = total_buff
		total_buff = value
		total_buff_changed.emit(old_value, total_buff)
	
	max_value_after_buffs = max_value + total_buff
