class_name StatRow
extends HBoxContainer

@onready var stat_name_label: Label = %StatNameLabel
@onready var stat_value_label: Label = %StatValueLabel
@onready var stat_increase_button: Button = %StatIncreaseButton

var stat: CharacterStat

signal pressed_stat_increase(player_stat: CharacterStat)

func _ready() -> void:
	stat_name_label.label_settings = LabelSettings.new()
	stat_value_label.label_settings = LabelSettings.new()
	pressed_stat_increase.connect(PlayerManager.apply_perk_point)
	PlayerManager.perk_points_changed.connect(check_perk_points)

func load_stat(stat: CharacterStat) -> void:
	self.stat = stat
	stat_name_label.text = stat.stat_name
	update_stat_value_label(stat)
	stat.max_value_after_buffs_changed.connect(func(old_value, new_value): update_stat_value_label(stat))
	check_perk_points(PlayerManager.current_player.perk_points_available)

# Updates the stat value label's text to match the stat's max_value_after_buffs.
# The label's font color is changed based on whether max_value_after_buffs
# is greater than max_value. For example, if it is greater, then the font color
# is set to GREEN to indicate that the value is buffed.
func update_stat_value_label(stat: CharacterStat) -> void:
	var label = stat_value_label
	label.text = str(stat.max_value_after_buffs)
	if stat.max_value_after_buffs > stat.max_value:
		label.label_settings.font_color = Color.GREEN
	elif stat.max_value_after_buffs < stat.max_value:
		label.label_settings.font_color = Color.RED
	else:
		label.label_settings.font_color = Color.WHITE

func _on_stat_increase_button_pressed() -> void:
	pressed_stat_increase.emit(stat)

func check_perk_points(points: int) -> void:
	if points > 0:
		stat_increase_button.disabled = false
		stat_increase_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		stat_increase_button.disabled = true
		stat_increase_button.mouse_default_cursor_shape = Control.CURSOR_ARROW
