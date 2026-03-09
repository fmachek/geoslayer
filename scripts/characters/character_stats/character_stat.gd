# Represents a character stat such as HP, speed, damage etc.
# This class can work with buffs and debuffs, handles maximum and current values and so on.

class_name CharacterStat
extends Node

@export var stat_name: String

@export var max_value: int # Default max value
@export var current_value: int
var max_value_after_buffs: int # Max value + any buffs and debuffs
# Important note:
# Max value after buffs is the value that is usually used for various calculations.
# For example, when speed is used for movement, what is really used is this value.
# While all of these 3 values are used for Max HP for example, for other stats
# such as speed, 'current_value' goes unused and is technically redundant.
# I might change the stats system in the future if this becomes annoying.
var total_buff: int = 0 # Sum of all buffs/debuffs

var buffs: Node # Node containing Buff nodes

signal max_value_changed(old_value: int, new_value: int)
signal current_value_changed(old_value: int, new_value: int)
signal max_value_after_buffs_changed(old_value: int, new_value: int)
signal total_buff_changed(old_value: int, new_value: int)

signal added_buff(buff: Buff)

func _ready():
	buffs = Node.new()
	buffs.name = "Buffs"
	add_child(buffs)
	max_value_after_buffs = max_value

# Adds a new buff to the list and calculates the total buff and applies it
func add_buff(buff: Buff) -> void:
	buffs.add_child(buff)
	added_buff.emit(buff)
	calculate_total_buff()

# Removes a buff from the list and calculates the total buff and applies it
func remove_buff(buff: Buff) -> void:
	buffs.remove_child(buff)
	buff.queue_free()
	calculate_total_buff()

# Calculates the total buff and applies it
func calculate_total_buff():
	var buff_sum = 0
	for buff: Buff in buffs.get_children():
		buff_sum += buff.amount
	change_total_buff(buff_sum)

# Changes the current value, checks for edge cases such as the new value
# exceeding the max value after buffs.
func change_current_value(value: int) -> void:
	if current_value == value:
		return
	if value > max_value_after_buffs:
		value = max_value_after_buffs
	if value < 0:
		value = 0
	var old_value = current_value
	current_value = value
	current_value_changed.emit(old_value, current_value)

# Changes the max value and recalculates the buff.
func change_max_value(value: int) -> void:
	if max_value == value:
		return
	var old_value = max_value
	max_value = value
	max_value_changed.emit(old_value, max_value)
	calculate_total_buff()

# Changes the max value after buffs
func change_max_value_after_buffs(value: int) -> void:
	if value < 0:
		value = 0
	if max_value_after_buffs == value:
		return
	var old_value = max_value_after_buffs
	max_value_after_buffs = value
	max_value_after_buffs_changed.emit(old_value, max_value_after_buffs)
	
	# Check if current value exceeds max value (can happen after debuffs)
	if current_value > max_value_after_buffs:
		change_current_value(max_value_after_buffs)

# Changes the total buff
func change_total_buff(value: int) -> void:
	if total_buff != value:
		var old_value = total_buff
		total_buff = value
		total_buff_changed.emit(old_value, total_buff)
	
	change_max_value_after_buffs(max_value + total_buff)

# Adds an amount to the current value
func add_value(value: int) -> void:
	change_current_value(current_value + value)
