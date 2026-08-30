class_name SettingsUI
extends Control

@onready var collapse_hud_button: CheckButton = %CollapseHUDButton

@onready var menu_button: Button = %BackToMenuButton


func _ready() -> void:
	collapse_hud_button.toggled.connect(set_collapse_hud)
	menu_button.pressed.connect(GameManager.switch_to_menu)
	_load_initial_values()


func set_collapse_hud(value: bool) -> void:
	ConfigManager.update_collapse_hud(value)


func _load_initial_values() -> void:
	collapse_hud_button.set_pressed_no_signal(ConfigManager.collapse_hud)


# Input handling from Godot Docs
# (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("escape"):
			GameManager.switch_to_menu()
