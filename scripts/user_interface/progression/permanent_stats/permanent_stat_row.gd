class_name PermanentStatRow
extends HBoxContainer

signal increase_pressed(stat_name: String)

var stat_name: String
var stat_value: int:
	set(value):
		stat_value = value
		_update_value_label()
@onready var name_label: Label = %StatNameLabel
@onready var value_label: Label = %StatValueLabel
@onready var increase_button: Button = %StatIncreaseButton


func _ready() -> void:
	increase_button.pressed.connect(_on_increase_button_pressed)
	UserManager.user_stat_points_changed.connect(_check_stat_points)
	_update_name_label()
	_update_value_label()
	_check_stat_points(UserManager.user_stat_points)


func _on_increase_button_pressed() -> void:
	increase_pressed.emit(stat_name)


func load_stat(stat: UserStat) -> void:
	self.stat_name = stat.stat_name
	self.stat_value = stat.stat_value
	stat.value_changed.connect(func(value: int): value_label.text = str(value))


func _update_name_label() -> void:
	if name_label:
		name_label.text = stat_name


func _update_value_label() -> void:
	if value_label:
		value_label.text = str(stat_value)


func _check_stat_points(amount: int) -> void:
	if amount > 0:
		increase_button.disabled = false
		increase_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		increase_button.disabled = true
		increase_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
