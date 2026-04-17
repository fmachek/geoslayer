# Displays the player's stats and their values.

class_name StatsTab
extends MarginContainer

var stat_row_scene: PackedScene = preload("res://scenes/user_interface/hud/stats_tab/stat_row.tscn")

# Connects the player_spawned signal to the load_player_stats
# function so that the player's stats can be loaded on spawn.
func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)

# Loads the player's stats. Iterates through the children of the
# CharacterStats node (which should be a child of every Character)
# and loads the labels for each one that is a CharacterStat.
func load_player_stats(player: PlayerCharacter) -> void:
	var stats_node: Node = player.get_node("CharacterStats")
	for stat_node_child in stats_node.get_children():
		if stat_node_child is CharacterStat:
			load_stat(stat_node_child)

func load_stat(stat: CharacterStat) -> void:
	var stat_row: StatRow = stat_row_scene.instantiate()
	%StatRowContainer.add_child(stat_row)
	stat_row.load_stat(stat)

func _on_player_spawned(player: PlayerCharacter) -> void:
	load_player_stats(player)
	update_perk_points_label(player.perk_points_available)
	player.perk_points_available_changed.connect(update_perk_points_label)

func update_perk_points_label(points: int) -> void:
	%StatPointsLabel.text = "Stat Points: %d" % points
