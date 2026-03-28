class_name ProgressionUI
extends Control

const _STAT_ROW_SCENE := preload(
		"res://scenes/user_interface/progression/permanent_stats/permanent_stat_row.tscn")

@onready var level_label: Label = %PlayerLevelLabel
@onready var level_bar: ProgressBar = %LevelProgressBar
@onready var menu_button: Button = %BackToMenuButton
@onready var stat_row_container: VBoxContainer = %StatRowContainer
@onready var stat_points_label: Label = %StatPointsLabel


func _ready() -> void:
	menu_button.pressed.connect(GameManager.switch_to_menu)
	UserManager.user_stat_points_changed.connect(_update_stat_points_label)
	_load_level()
	_load_user_stats()
	_update_stat_points_label(UserManager.user_stat_points)


func _load_level() -> void:
	var user_level: Level = UserManager.user_level
	var current_level: int = user_level.current_level
	var current_xp: int = user_level.current_xp
	var xp_required: int = user_level.required_xp
	level_label.text = "Player level: %d" % current_level
	level_bar.max_value = xp_required
	level_bar.value = current_xp


func _load_user_stats() -> void:
	var user_stats: Array[UserStat] = UserManager.user_stats
	for stat: UserStat in user_stats:
		_load_stat(stat)


func _load_stat(stat: UserStat) -> void:
	var stat_row: PermanentStatRow = _STAT_ROW_SCENE.instantiate()
	stat_row.load_stat(stat)
	stat_row.increase_pressed.connect(UserManager.increase_stat)
	stat_row_container.add_child(stat_row)


func _update_stat_points_label(amount: int) -> void:
	stat_points_label.text = "Stat points available: %d" % amount
