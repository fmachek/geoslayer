class_name StatsTab
extends MarginContainer
## Represents a tab in the UI which allows the player to upgrade
## their stats.

const _STAT_ROW_SCENE := preload(
		"res://scenes/user_interface/hud/stats_tab/stat_row.tscn")

@onready var _row_container: VBoxContainer = %StatRowContainer
@onready var _points_label: Label = %StatPointsLabel


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)


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


func _on_player_spawned(player: PlayerCharacter) -> void:
	load_player_stats(player)
	_update_perk_points_label(player.perk_points_available)
	player.perk_points_available_changed.connect(_update_perk_points_label)


func _update_perk_points_label(points: int) -> void:
	_points_label.text = "Stat Points: %d" % points
