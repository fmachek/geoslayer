class_name StatRow
extends HBoxContainer
## Represents a [CharacterStat] in the UI and allows upgrading it through
## the UI using stat points.

## Emitted when the increase button is pressed.
signal pressed_stat_increase(player_stat: CharacterStat)
## Emitted when the stack increase button is pressed.
signal pressed_stat_stack_increase(player_stat: CharacterStat, amount: int)

## The [CharacterStat] represented by the [StatRow].
var stat: CharacterStat
## Amount of perk points applied when the stack increase button is pressed.
var stack_increase: int = 5

@onready var _name_label: Label = %StatNameLabel
@onready var _value_label: Label = %StatValueLabel
@onready var _increase_button: Button = %StatIncreaseButton
@onready var _stack_increase_button: Button = %StatStackIncreaseButton


func _ready() -> void:
	_set_label_settings()
	pressed_stat_increase.connect(PlayerManager.apply_perk_point)
	pressed_stat_stack_increase.connect(PlayerManager.apply_perk_point_stack)
	PlayerManager.perk_points_changed.connect(check_perk_points)
	_stack_increase_button.get_node("HBoxContainer/AmountLabel").text = str(stack_increase)


## Loads a given [param stat].
func load_stat(stat: CharacterStat) -> void:
	self.stat = stat
	_name_label.text = stat.stat_name
	update_stat_value_label(stat)
	stat.max_value_after_buffs_changed.connect(
			func(old_value, new_value): update_stat_value_label(stat))
	check_perk_points(PlayerManager.current_player.perk_points_available)


## Disables/enables the increase buttons based on the amount of [param points].
## Also updates the cursor shown when hovering over them.
func check_perk_points(points: int) -> void:
	_update_increase_button(_increase_button, points, 1)
	_update_increase_button(_stack_increase_button, points, stack_increase)


func _update_increase_button(button: Button, points: int, req_points: int) -> void:
	if points >= req_points:
		button.disabled = false
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		button.disabled = true
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW


## Updates the value label to match the [param stat].
## Changes the color of the label font based on whether
## the [param stat] is overall buffed or debuffed.
func update_stat_value_label(stat: CharacterStat) -> void:
	var label = _value_label
	label.text = str(stat.max_value_after_buffs)
	if stat.is_percentage_based:
		label.text += "%"
	if stat.max_value_after_buffs > stat.max_value:
		label.label_settings.font_color = Color.GREEN
	elif stat.max_value_after_buffs < stat.max_value:
		label.label_settings.font_color = Color.RED
	else:
		label.label_settings.font_color = Color.WHITE


func _on_stat_increase_button_pressed() -> void:
	pressed_stat_increase.emit(stat)


func _on_stat_stack_increase_button_pressed() -> void:
	pressed_stat_stack_increase.emit(stat, stack_increase)


func _set_label_settings() -> void:
	_name_label.label_settings = LabelSettings.new()
	_name_label.label_settings.outline_size = 8
	_name_label.label_settings.outline_color = Color.BLACK
	_value_label.label_settings = LabelSettings.new()
	_value_label.label_settings.outline_size = 8
	_value_label.label_settings.outline_color = Color.BLACK
