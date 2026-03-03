extends HBoxContainer

var player: PlayerCharacter
@onready var progress_bar: ProgressBar = $LevelProgressBar
@onready var level_label: Label = $LevelLabel
var current_level_shown: int

var level_up_tween: Tween

func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)

func _on_player_spawned(player: PlayerCharacter):
	load_player(player)

func load_player(player: PlayerCharacter):
	self.player = player
	var level: Level = player.level

	update_required_xp(level.required_xp)
	update_current_xp(level.current_xp)
	update_level(level.current_level)
	
	level.current_xp_changed.connect(update_current_xp)
	level.level_changed.connect(update_level)
	level.required_xp_changed.connect(update_required_xp)

func update_current_xp(new_xp: int):
	progress_bar.value = new_xp

func update_required_xp(new_xp: int):
	progress_bar.max_value = new_xp

func update_level(new_level: int):
	if current_level_shown:
		if new_level > current_level_shown:
			play_level_up_tween()
	current_level_shown = new_level
	$LevelLabel.text = "Level " + str(new_level)

func play_level_up_tween():
	if level_up_tween:
		level_up_tween.kill()
	level_label.add_theme_color_override("font_color", Color("bb00bb"))
	level_up_tween = create_tween()
	level_up_tween.tween_property(level_label, "theme_override_colors/font_color", Color("ffffffff"), 0.5)
