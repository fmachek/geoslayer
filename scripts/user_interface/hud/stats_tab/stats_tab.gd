class_name StatsTab
extends PanelContainer
## Represents a tab in the UI which allows the player to upgrade
## their stats.

## Emitted when the player gains stat points and the [StatsTab]
## detects it.
signal gained_stat_points()
## Emitted when the player gains stat points while the tab is hidden.
signal gained_points_while_hidden()
## Emitted when a stat increase button is pressed.
signal pressed_increase()
## Emitted when visibility changes to true.
signal opened()

const _STAT_ROW_SCENE := preload(
		"res://scenes/user_interface/hud/stats_tab/stat_row.tscn")

@onready var _row_container: VBoxContainer = %StatRowContainer
@onready var _points_label: Label = %StatPointsLabel


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)
	gained_stat_points.connect(_enable_panel_highlight)
	pressed_increase.connect(_disable_panel_highlight)


## Loads a [StatRow] for each one of the [param player]'s
## [CharacterStat]s.
func load_player_stats(player: PlayerCharacter) -> void:
	var stats_node: Node = player.get_node("CharacterStats")
	for stat_node_child in stats_node.get_children():
		if stat_node_child is CharacterStat:
			load_stat(stat_node_child)


## Loads a [StatRow] for a given [param stat].
func load_stat(stat: CharacterStat) -> void:
	var stat_row: StatRow = _STAT_ROW_SCENE.instantiate()
	_row_container.add_child(stat_row)
	stat_row.load_stat(stat)
	stat_row.pressed_stat_increase.connect(pressed_increase.emit.unbind(1))
	stat_row.pressed_stat_stack_increase.connect(pressed_increase.emit.unbind(2))


func _on_player_spawned(player: PlayerCharacter) -> void:
	load_player_stats(player)
	_update_perk_points_label(player.perk_points_available)
	player.perk_points_available_changed.connect(_update_perk_points_label)
	player.gained_perk_points.connect(_on_gained_points.unbind(1))
	if player.perk_points_available > 0:
		_enable_panel_highlight()


func _update_perk_points_label(points: int) -> void:
	_points_label.text = "Stat Points: %d" % points
	if points > 0:
		_points_label.label_settings.font_color = Color("00ff00")
	else:
		_points_label.label_settings.font_color = Color("c0c0c0")


func _on_gained_points() -> void:
	gained_stat_points.emit()
	if not visible:
		gained_points_while_hidden.emit()


func _on_close_button_pressed() -> void:
	hide()


func _on_visibility_changed() -> void:
	if visible:
		opened.emit()


func _enable_panel_highlight() -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	stylebox.set_border_width_all(2)


func _disable_panel_highlight() -> void:
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	stylebox.set_border_width_all(0)
