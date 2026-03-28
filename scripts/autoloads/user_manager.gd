# Godot Docs helped me with saving and loading:
# https://docs.godotengine.org/en/stable/classes/class_configfile.html#class-configfile

extends Node
## Manages user data which is saved to and loaded from a config file.

## The file path at which the user config is saved.
const CONFIG_PATH := "user://project01_user.cfg"

## The current user level.
var user_level: Level
## User level before the last change (usually before gaining XP).
var user_level_before_change: Level


## Attempts to load a user from the config file at [member CONFIG_PATH].
## If the load fails, a new user is created and then saved.
func load_user() -> void:
	var config := ConfigFile.new()
	
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("Config not found, creating new user.")
		_load_user_level(1, 0, 100)
		return
	
	var sections: PackedStringArray = config.get_sections()
	if not sections.is_empty():
		var user = sections[0]
		var level: int = config.get_value(user, "Level")
		var current_xp: int = config.get_value(user, "CurrentXP")
		var required_xp: int = config.get_value(user, "RequiredXP")
		print("Loaded user with level %d (XP: %d). Required XP: %d." % [level, current_xp, required_xp])
		_load_user_level(level, current_xp, required_xp)


## Attempts to save the user to a config file at [member CONFIG_PATH].
func save_user() -> void:
	var config := ConfigFile.new()
	
	config.set_value("User", "Level", user_level.current_level)
	config.set_value("User", "CurrentXP", user_level.current_xp)
	config.set_value("User", "RequiredXP", user_level.required_xp)
	
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_user()


func _load_user_level(current_level: int, xp: int, required_xp: int) -> void:
	user_level = Level.new()
	user_level.current_level = current_level
	user_level.current_xp = xp
	user_level.required_xp = required_xp
	save_user()


func _update_user_level_before_change() -> void:
	user_level_before_change = Level.new()
	user_level_before_change.current_level = user_level.current_level
	user_level_before_change.current_xp = user_level.current_xp
	user_level_before_change.required_xp = user_level.required_xp
