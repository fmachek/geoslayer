class_name WorldSelectionButton
extends Button

@export var world_number: int

@onready var _locked_indicator: Control = $LockedIndicator


func _ready() -> void:
	text = str(world_number)
	if WorldManager.is_world_unlocked(world_number):
		set_to_unlocked()
	else:
		set_to_locked()


func change_world_number(new_number: int) -> void:
	world_number = new_number
	text = str(world_number)


func set_to_locked() -> void:
	_locked_indicator.show()
	disabled = true
	var req_level: int = WorldManager.get_world_required_level(world_number)
	tooltip_text = "Level %d is required to enter this world." % req_level
	mouse_default_cursor_shape = Control.CURSOR_ARROW


func set_to_unlocked() -> void:
	_locked_indicator.hide()
	disabled = false
	tooltip_text = ""
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
