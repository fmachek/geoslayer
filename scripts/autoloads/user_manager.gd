# Godot Docs helped me with saving and loading:
# https://docs.godotengine.org/en/stable/classes/class_configfile.html#class-configfile

extends Node
## Manages user data which is saved to and loaded from a config file.

## Emitted when [member user_stat_points] changes.
signal user_stat_points_changed(new_points: int)

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
var was_load_successful: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_user()


## Attempts to load a user from the config file at [member CONFIG_PATH].
## If the load fails, a new user is created and then saved.
## Partial loads are also handled. If a value is missing, it is set to
## the default value.
func load_user() -> void:
	var config := ConfigFile.new()
	
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("Config not found, creating new user.")
		create_new_user()
		return
	
	var sections: PackedStringArray = config.get_sections()
	if not sections.is_empty():
		var is_load_incomplete: bool = false
		var user = sections[0]
		
		var level = config.get_value(user, "Level")
		if level is not int:
			level = 1
			is_load_incomplete = true
		
		var current_xp = config.get_value(user, "CurrentXP")
		if current_xp is not int:
			current_xp = 0
			is_load_incomplete = true
		
		var required_xp = config.get_value(user, "RequiredXP")
		if required_xp is not int:
			required_xp = 100
			is_load_incomplete = true
		
		var health = config.get_value(user, "Health")
		if health is not int:
			health = 0
			is_load_incomplete = true
		
		var armor = config.get_value(user, "Armor")
		if armor is not int:
			armor = 0
			is_load_incomplete = true
		
		var damage = config.get_value(user, "Damage")
		if damage is not int:
			damage = 0
			is_load_incomplete = true
		
		var speed = config.get_value(user, "Speed")
		if speed is not int:
			speed = 0
			is_load_incomplete = true
		
		var stat_points = config.get_value(user, "StatPoints")
		if stat_points is not int:
			stat_points = 0
			is_load_incomplete = true
		user_stat_points = stat_points
		
		print("Loaded user with level %d (XP: %d). Required XP: %d." % [level, current_xp, required_xp])
		print("User stats: health (%d), damage (%d), speed (%d)" % [health, damage, speed])
		_load_user_level(level, current_xp, required_xp)
		_load_stats(health, armor, damage, speed)
		was_load_successful = true
		
		if is_load_incomplete:
			save_user()
	else:
		create_new_user()


## Creates a new user with default values.
func create_new_user() -> void:
	_load_user_level(1, 0, 100)
	_load_stats(0, 0, 0, 0)
	user_stat_points = 0
	save_user()


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
