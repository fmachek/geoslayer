class_name TextureManager
extends Node
## Helps with managing texture paths.

## Path to a placeholder texture.
static var placeholder_texture_path := "res://assets/user_interface/placeholder.png"
static var _ability_icon_dir := "res://assets/user_interface/abilities/"
static var _enemy_icon_dir := "res://assets/user_interface/enemies/"


## Returns a path to an ability icon if found. Otherwise returns
## a path to a placeholder texture.
static func get_ability_icon_path(ability_name: String) -> String:
	var ability_icon_path := _ability_icon_dir + ability_name.to_lower() + ".png"
	if ResourceLoader.exists(ability_icon_path):
		return ability_icon_path
	else:
		return placeholder_texture_path


static func get_enemy_icon_path(enemy_name: String) -> String:
	var enemy_icon_path := _enemy_icon_dir + enemy_name.to_lower() + ".png"
	if ResourceLoader.exists(enemy_icon_path):
		return enemy_icon_path
	else:
		return placeholder_texture_path
