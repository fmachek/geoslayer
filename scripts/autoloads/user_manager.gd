# Godot Docs helped me with saving and loading:
# https://docs.godotengine.org/en/stable/classes/class_configfile.html#class-configfile

extends Node
## Manages user data which is saved to and loaded from a config file.

## Emitted when [member user_stat_points] changes.
signal user_stat_points_changed(new_points: int)

enum LoadStatus {
	NOT_FOUND,
	SUCCESS,
	INCOMPLETE,
	FAIL
}

## The file path at which the user config is saved.
const CONFIG_PATH := "user://user.cfg"
## Amount of stat points given to the user on every level up.
const STAT_POINTS_PER_LEVEL: int = 5

## The current user level.
var user_level: Level
## User level before the last change (usually before gaining XP).
var user_level_before_change: Level
## Amount of stat points available to spend.
var user_stat_points: int:
	set(value):
		user_stat_points = value
		user_stat_points_changed.emit(value)
## Array of permanent stat upgrades.
var user_stats: Array[UserStat] = []
## Says whether the user load was successful or not.
var load_status: LoadStatus = LoadStatus.NOT_FOUND


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_user()


## Loads user data from a config file at [member CONFIG_PATH].
## If any data is missing from the config, a new user is created.
## No partial loads are done.
func load_user() -> void:
	var config := ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err != OK:
		# Config doesn't exist at all - create new user.
		load_status = LoadStatus.NOT_FOUND
		print("Config not found, creating new user.")
		create_new_user()
		return
	
	var sections: PackedStringArray = config.get_sections()
	var expected_sections: Array[String] = ["Level", "Stats"]
	
	# Missing sections - create new user, ignore existing sections.
	if sections.size() != expected_sections.size():
		load_status = LoadStatus.INCOMPLETE
		print("Missing sections in user config file. Creating new user.")
		create_new_user()
		return
	
	var level_section = sections[0]
	var stat_section = sections[1]
	# Check for incorrect section names.
	if level_section != "Level" or stat_section != "Stats":
		load_status = LoadStatus.INCOMPLETE
		print("User config is not in the correct format. Creating new user.")
		create_new_user()
		return
	
	# Load level data first
	var level_data: Dictionary[String, int] = load_level_from_config(config, level_section)
	if level_data.is_empty():
		load_status = LoadStatus.INCOMPLETE
		print("User level data is missing. Creating new user.")
		create_new_user()
		return
	
	var stats_data: Dictionary[String, int] = load_stats_from_config(config, stat_section)
	if stats_data.is_empty():
		load_status = LoadStatus.INCOMPLETE
		print("User stat data is missing. Creating new user.")
		create_new_user()
		return
	
	var level: int = level_data.get("Level")
	var current_xp: int = level_data.get("CurrentXP")
	var required_xp: int = level_data.get("RequiredXP")
	
	var stat_points: int = stats_data.get("StatPoints")
	var health: int = stats_data.get("Health")
	var armor: int = stats_data.get("Armor")
	var damage: int = stats_data.get("Damage")
	var speed: int = stats_data.get("Speed")
	
	print("Loaded user with level %d (XP: %d). Required XP: %d." % [level, current_xp, required_xp])
	print("User stats: health (%d), armor (%d), damage (%d), speed (%d)" % [health, armor, damage, speed])
	_load_user_level(level, current_xp, required_xp)
	_load_stats(health, armor, damage, speed)
	user_stat_points = stat_points
	
	load_status = LoadStatus.SUCCESS


func load_level_from_config(config: ConfigFile, section: String) -> Dictionary[String, int]:
	var value_names: Array[String] = ["Level", "CurrentXP", "RequiredXP"]
	return load_integers_from_section(config, section, value_names)


func load_stats_from_config(config: ConfigFile, section: String) -> Dictionary[String, int]:
	var value_names: Array[String] = ["StatPoints", "Health", "Armor", "Damage", "Speed"]
	return load_integers_from_section(config, section, value_names)


func load_integers_from_section(config: ConfigFile, section: String, value_names: Array[String]) -> Dictionary[String, int]:
	var values: Dictionary[String, int] = {}
	for value_name in value_names:
		var value = config.get_value(section, value_name)
		if value is not int:
			# Return empty dictionary
			return {}
		else:
			values.set(value_name, value)
	return values


## Creates a new user with default values.
func create_new_user() -> void:
	_load_user_level(1, 0, 100)
	_load_stats(0, 0, 0, 0)
	user_stat_points = 0
	save_user()


## Attempts to save the user to a config file at [member CONFIG_PATH].
func save_user() -> void:
	var config := ConfigFile.new()
	
	config.set_value("Level", "Level", user_level.current_level)
	config.set_value("Level", "CurrentXP", user_level.current_xp)
	config.set_value("Level", "RequiredXP", user_level.required_xp)
	config.set_value("Stats", "StatPoints", user_stat_points)
	
	for stat: UserStat in user_stats:
		config.set_value("Stats", stat.stat_name, stat.stat_value)
	
	var err = config.save(CONFIG_PATH)
	if err != OK:
		print("Something went wrong while saving user data.")
	else:
		print("Successfully saved user data.")


## Adds an [param amount] of XP to the user level.
## Also clones the level before the change and saves it as
## [member user_level_before_change].[br][br]
## Also attempts to save the user to a config file.
func add_xp(amount: int) -> void:
	_update_user_level_before_change()
	user_level.add_xp(amount)
	print("The user has gained %d XP." % amount)
	save_user()


## If the user has any [member user_stat_points], one
## point is spent and the stat's value is increased by 1.
func increase_stat(stat_name: String) -> void:
	if user_stat_points == 0:
		return
	for stat: UserStat in user_stats:
		if stat.stat_name == stat_name:
			user_stat_points -= 1
			stat.stat_value += 1


## Gives a single stat point to the user and saves the data.
func add_stat_point() -> void:
	user_stat_points += 1
	save_user()


func _load_user_level(current_level: int, xp: int, required_xp: int) -> void:
	user_level = Level.new()
	user_level.current_level = current_level
	user_level.current_xp = xp
	user_level.required_xp = required_xp
	user_level.level_changed.connect(_on_user_level_changed.unbind(1))


func _load_stats(health: int, armor: int, damage: int, speed: int) -> void:
	user_stats.clear()
	user_stats.append(UserStat.new("Health", health))
	user_stats.append(UserStat.new("Armor", armor))
	user_stats.append(UserStat.new("Damage", damage))
	user_stats.append(UserStat.new("Speed", speed))
	for stat in user_stats:
		stat.value_changed.connect(save_user.unbind(1))


func _update_user_level_before_change() -> void:
	user_level_before_change = Level.new()
	user_level_before_change.current_level = user_level.current_level
	user_level_before_change.current_xp = user_level.current_xp
	user_level_before_change.required_xp = user_level.required_xp


func _on_user_level_changed() -> void:
	user_stat_points += STAT_POINTS_PER_LEVEL
