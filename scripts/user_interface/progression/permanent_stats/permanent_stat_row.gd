class_name PermanentStatRow
extends HBoxContainer
## Represents a player's permanent stat in the UI, similar to
## [StatRow].

## Emitted when the increase button is pressed.
signal increase_pressed(stat_name: String)

## Name of the stat.
var stat_name: String
## Value of the stat.
var stat_value: int:
	set(value):
		stat_value = value
		_update_value_label()

@onready var _name_label: Label = %StatNameLabel
@onready var _value_label: Label = %StatValueLabel
@onready var _increase_button: Button = %StatIncreaseButton


func _ready() -> void:
	_increase_button.pressed.connect(_on_increase_button_pressed)
	UserManager.user_stat_points_changed.connect(_check_stat_points)
	_update_name_label()
	_update_value_label()
	_check_stat_points(UserManager.user_stat_points)


## Loads the [PermanentStatRow] so that it represents the
## given [param stat].
func load_stat(stat: UserStat) -> void:
	self.stat_name = stat.stat_name
	self.stat_value = stat.stat_value
	stat.value_changed.connect(func(value: int): _value_label.text = str(value))


func _on_increase_button_pressed() -> void:
	increase_pressed.emit(stat_name)


func _update_name_label() -> void:
	if _name_label:
		_name_label.text = stat_name


func _update_value_label() -> void:
	if _value_label:
		_value_label.text = str(stat_value)


func _check_stat_points(amount: int) -> void:
	if amount > 0:
		_increase_button.disabled = false
		_increase_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		_increase_button.disabled = true
		_increase_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
