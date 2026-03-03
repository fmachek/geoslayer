class_name Level
extends Node

@export var required_xp: int = 100
@export var current_xp: int = 0
@export var current_level: int = 1

signal level_changed(new_level: int)
signal current_xp_changed(new_xp: int)
signal required_xp_changed(new_xp: int)

func add_xp(xp: int):
	while (current_xp + xp) >= required_xp:
		xp -= (required_xp - current_xp)
		level_up()
	current_xp += xp
	current_xp_changed.emit(current_xp)

func level_up():
	current_xp = 0
	current_xp_changed.emit(current_xp)
	
	current_level += 1
	level_changed.emit(current_level)
	
	required_xp *= 1.3 # Required XP increases with each new level
	required_xp_changed.emit(required_xp)
