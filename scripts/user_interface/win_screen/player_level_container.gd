class_name PlayerLevelContainer
extends VBoxContainer

@onready var level: Level = %MockLevel
@onready var level_label: Label = %PlayerLevelLabel
@onready var bar: ProgressBar = %LevelProgressBar


func _ready() -> void:
	_load_mock_level()
	_update_all()


func _load_mock_level() -> void:
	var original_level: Level = UserManager.user_level_before_change
	level.current_level = original_level.current_level
	level.current_xp = original_level.current_xp
	level.required_xp = original_level.required_xp
	
	level.current_xp_changed.connect(_update_progress_bar.unbind(1))
	level.required_xp_changed.connect(_update_progress_bar.unbind(1))
	level.level_changed.connect(_update_level_label.unbind(1))


func _update_progress_bar() -> void:
	bar.max_value = level.required_xp
	bar.value = level.current_xp


func _update_level_label() -> void:
	level_label.text = "Current player level: %d" % level.current_level


func _update_all() -> void:
	_update_progress_bar()
	_update_level_label()
