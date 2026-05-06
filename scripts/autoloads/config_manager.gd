# Godot Docs helped me with saving and loading:
# https://docs.godotengine.org/en/stable/classes/class_configfile.html#class-configfile
extends Node

const CONFIG_PATH: String = "user://config.cfg"

var chosen_world: int


func _ready() -> void:
	load_config()


func load_config() -> void:
	var config := ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("Config not found, creating new config.")
		create_new_config()
		return
	var sections: PackedStringArray = config.get_sections()
	if not sections.is_empty():
		var cfg_section = sections[0]
		var world = config.get_value(cfg_section, "Chosen world")
		if world is not int:
			world = 1
		chosen_world = world


func save_config() -> void:
	var config := ConfigFile.new()
	config.set_value("Configuration", "Chosen world", chosen_world)
	var err = config.save(CONFIG_PATH)
	if err != OK:
		print("Something went wrong while saving config.")
	else:
		print("Successfully saved config.")


func create_new_config() -> void:
	chosen_world = 1
	save_config()


func update_chosen_world(new_world: int) -> void:
	chosen_world = new_world
	save_config()
