class_name ProgressionUI
extends Control
## Represents the progression UI screen where the player can
## upgrade their permanent stats and more.

const _STAT_ROW_SCENE := preload(
		"res://scenes/user_interface/progression/permanent_stats/permanent_stat_row.tscn")

@onready var _level_label: Label = %PlayerLevelLabel
@onready var _level_bar: ProgressBar = %LevelProgressBar
@onready var _menu_button: Button = %BackToMenuButton
@onready var _stat_row_container: VBoxContainer = %StatRowContainer
@onready var _stat_points_label: Label = %StatPointsLabel
@onready var _next_world_unlock: HBoxContainer = %NextWorldUnlock
@onready var _world_unlock_label: Label = %WorldUnlockLabel


func _ready() -> void:
	_menu_button.pressed.connect(GameManager.switch_to_menu)
	UserManager.user_stat_points_changed.connect(_update_stat_points_label)
	_load_level()
	_load_user_stats()
	_update_stat_points_label(UserManager.user_stat_points)
	_update_next_world_unlock()


func _load_level() -> void:
	var user_level: Level = UserManager.user_level
	var current_level: int = user_level.current_level
	var current_xp: int = user_level.current_xp
	var xp_required: int = user_level.required_xp
	_level_label.text = "Player level: %d" % current_level
	_level_bar.max_value = xp_required
	_level_bar.value = current_xp


func _load_user_stats() -> void:
	var user_stats: Array[UserStat] = UserManager.user_stats
	for stat: UserStat in user_stats:
		_load_stat(stat)


func _load_stat(stat: UserStat) -> void:
	var stat_row: PermanentStatRow = _STAT_ROW_SCENE.instantiate()
	stat_row.load_stat(stat)
	stat_row.increase_pressed.connect(UserManager.increase_stat)
	_stat_row_container.add_child(stat_row)


func _update_stat_points_label(amount: int) -> void:
	_stat_points_label.text = "Stat points available: %d" % amount


func _update_next_world_unlock() -> void:
	var next_unlock: int = WorldManager.get_next_world_unlock()
	if next_unlock == -1: # No more worlds to unlock
		_next_world_unlock.hide()
	else:
		var req_level: int = WorldManager.get_world_required_level(next_unlock)
		_world_unlock_label.text = "World %d at Level %d" % [next_unlock, req_level]
