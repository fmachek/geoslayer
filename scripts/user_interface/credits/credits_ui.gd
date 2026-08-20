class_name CreditsUI
extends Control

@onready var menu_button: Button = %BackToMenuButton


func _ready() -> void:
	menu_button.pressed.connect(GameManager.switch_to_menu)


# Input handling from Godot Docs
# (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
func _unhandled_input(event) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			GameManager.switch_to_menu()
