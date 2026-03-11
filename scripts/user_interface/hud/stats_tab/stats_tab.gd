# Displays the player's stats and their values.

class_name StatsTab
extends MarginContainer

# Connects the player_spawned signal to the load_player_stats
# function so that the player's stats can be loaded on spawn.
func _ready() -> void:
	PlayerManager.player_spawned.connect(load_player_stats)

# Loads the player's stats. Iterates through the children of the
# CharacterStats node (which should be a child of every Character)
# and loads the labels for each one that is a CharacterStat.
func load_player_stats(player: PlayerCharacter) -> void:
	var stats_node: Node = player.get_node("CharacterStats")
	for stat_node_child in stats_node.get_children():
		if stat_node_child is CharacterStat:
			load_stat(stat_node_child)

# Loads a name and value label for a given CharacterStat.
# The max_value_after_buffs_changed signal from the stat is connected
# and triggers an update of the value label.
func load_stat(stat: CharacterStat) -> void:
	var stat_name_container: VBoxContainer = %StatNameContainer
	var stat_value_container: VBoxContainer = %StatValueContainer
	
	var stat_name_label: Label = Label.new()
	stat_name_label.label_settings = LabelSettings.new()
	stat_name_label.text = stat.stat_name
	
	var stat_value_label: Label = Label.new()
	stat_value_label.label_settings = LabelSettings.new()
	update_stat_value_label(stat, stat_value_label)
	
	stat_name_container.add_child(stat_name_label)
	stat_value_container.add_child(stat_value_label)
	
	stat.max_value_after_buffs_changed.connect(func(old_value, new_value): update_stat_value_label(stat, stat_value_label))

# Updates a given value label's text to match se stat's max_value_after_buffs.
# The label's font color is changed based on whether max_value_after_buffs
# is greater than max_value. For example, if it is greater, then the font color
# is set to GREEN to indicate that the value is buffed.
func update_stat_value_label(stat: CharacterStat, label: Label) -> void:
	label.text = str(stat.max_value_after_buffs)
	if stat.max_value_after_buffs > stat.max_value:
		label.label_settings.font_color = Color.GREEN
	elif stat.max_value_after_buffs < stat.max_value:
		label.label_settings.font_color = Color.RED
	else:
		label.label_settings.font_color = Color.WHITE
