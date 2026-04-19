class_name LevelHUD
extends HBoxContainer
## Represents a UI element displaying the player's level and
## the current progress toward the next level.

## Reference to the player's character.
var player: PlayerCharacter
## Current level being shown.
var current_level_shown: int = 1
var _level_up_tween: Tween

@onready var _progress_bar: ProgressBar = $LevelProgressBar
@onready var _level_label: Label = $LevelLabel


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)


## Sets the [LevelHUD] up so that it displays a [param player]'s
## [Level].
func load_player(player: PlayerCharacter):
	self.player = player
	var level: Level = player.level

	_update_required_xp(level.required_xp)
	_update_current_xp(level.current_xp)
	_update_level(level.current_level)
	
	level.current_xp_changed.connect(_update_current_xp)
	level.level_changed.connect(_update_level)
	level.required_xp_changed.connect(_update_required_xp)


func _update_level(new_level: int):
	if current_level_shown:
		if new_level > current_level_shown:
			_play_level_up_tween()
	current_level_shown = new_level
	_level_label.text = "Level %d" % new_level


func _update_current_xp(new_xp: int):
	_progress_bar.value = new_xp


func _update_required_xp(new_xp: int):
	_progress_bar.max_value = new_xp


func _on_player_spawned(player: PlayerCharacter):
	load_player(player)


func _play_level_up_tween():
	if _level_up_tween:
		_level_up_tween.kill()
	_level_label.add_theme_color_override("font_color", Color("bb00bb"))
	_level_up_tween = create_tween()
	_level_up_tween.tween_property(
			_level_label, "theme_override_colors/font_color", Color("ffffffff"), 0.5)
