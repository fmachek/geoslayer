class_name WorldSelectionButton
extends Button
## Represents a button in the [WorldSelectionUI] which selects
## a world upon being pressed. It can display a locked or unlocked
## world.

## Number of the [World] the button represents.
@export var world_number: int

@onready var _locked_indicator: Control = $LockedIndicator
@onready var _highlight_panel: Panel = $HighlightPanel


func _ready() -> void:
	text = str(world_number)
	if WorldManager.is_world_unlocked(world_number):
		set_to_unlocked()
	else:
		set_to_locked()


## Changes [member world_number] and updates the text.
func change_world_number(new_number: int) -> void:
	world_number = new_number
	text = str(world_number)


## Disables the button and causes it to switch to the locked look.
## It also sets a tooltip which says how high of a level is required
## to enter the world.
func set_to_locked() -> void:
	_locked_indicator.show()
	disabled = true
	var req_level: int = WorldManager.get_world_required_level(world_number)
	tooltip_text = "Level %d is required to enter this world." % req_level
	mouse_default_cursor_shape = Control.CURSOR_ARROW


## Enables the button and causes it to switch to the unlocked look.
func set_to_unlocked() -> void:
	_locked_indicator.hide()
	disabled = false
	tooltip_text = ""
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


## Checks if [param new_world_number] matches [member world_number].
## If it does, the button is highlighted, otherwise the highlight is hidden.
func check_new_number(new_world_number: int) -> void:
	if new_world_number == world_number:
		_turn_highlight_on()
	else:
		_turn_highlight_off()


func _turn_highlight_on() -> void:
	_highlight_panel.show()


func _turn_highlight_off() -> void:
	_highlight_panel.hide()
