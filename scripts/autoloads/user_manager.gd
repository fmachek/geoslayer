# Godot Docs helped me with saving and loading:
# https://docs.godotengine.org/en/stable/classes/class_configfile.html#class-configfile

extends Node
## Manages user data which is saved to and loaded from a config file.

## Emitted when [member user_stat_points] changes.
signal user_stat_points_changed(new_points: int)

## The file path at which the user config is saved.
const CONFIG_PATH := "user://project01_user.cfg"
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


## Attempts to load a user from the config file at [member CONFIG_PATH].
## If the load fails, a new user is created and then saved.
func load_user() -> void:
	var config := ConfigFile.new()
	
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("Config not found, creating new user.")
		_load_user_level(1, 0, 100)
		_load_stats(0, 0, 0, 0)
		user_stat_points = 0
		save_user()
		return
	
	var sections: PackedStringArray = config.get_sections()
	if not sections.is_empty():
		var user = sections[0]
		var level: int = config.get_value(user, "Level")
		var current_xp: int = config.get_value(user, "CurrentXP")
		var required_xp: int = config.get_value(user, "RequiredXP")
		var health: int = config.get_value(user, "Health")
		var armor: int = config.get_value(user, "Armor")
		var damage: int = config.get_value(user, "Damage")
		var speed: int = config.get_value(user, "Speed")
		user_stat_points = config.get_value(user, "StatPoints")
		print("Loaded user with level %d (XP: %d). Required XP: %d." % [level, current_xp, required_xp])
		print("User stats: health (%d), damage (%d), speed (%d)" % [health, damage, speed])
		_load_user_level(level, current_xp, required_xp)
		_load_stats(health, armor, damage, speed)


## Attempts to save the user to a config file at [member CONFIG_PATH].
func save_user() -> void:
	var config := ConfigFile.new()
	
	config.set_value("User", "Level", user_level.current_level)
	config.set_value("User", "CurrentXP", user_level.current_xp)
	config.set_value("User", "RequiredXP", user_level.required_xp)
	config.set_value("User", "StatPoints", user_stat_points)
	
	for stat: UserStat in user_stats:
		config.set_value("User", stat.stat_name, stat.stat_value)
	
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_user()


func _load_user_level(current_level: int, xp: int, required_xp: int) -> void:
	user_level = Level.new()
	user_level.current_level = current_level
	user_level.current_xp = xp
	user_level.required_xp = required_xp
	user_level.level_changed.connect(_on_user_level_changed)


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


func _on_user_level_changed(new_level: int) -> void:
	user_stat_points += STAT_POINTS_PER_LEVEL
