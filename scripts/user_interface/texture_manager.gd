class_name TextureManager
extends Node
## Helps with managing texture paths.

## Path to a placeholder texture.
static var placeholder_texture_path := "res://assets/user_interface/placeholder.png"
static var _ability_icon_dir := "res://assets/user_interface/abilities/"


## Returns a path to an ability icon if found. Otherwise returns
## a path to a placeholder texture.
static func get_ability_icon_path(ability_name: String) -> String:
	var ability_icon_path := _ability_icon_dir + ability_name.to_lower() + ".png"
	if ResourceLoader.exists(ability_icon_path):
		return ability_icon_path
	else:
		return placeholder_texture_path
