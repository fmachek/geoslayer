class_name MenuButtonContainer
extends VBoxContainer
## Represents a button container in the main menu. It connects its buttons'
## pressed signal to various methods.

@onready var play_button: Button = $PlayButton
@onready var shop_button: Button = $ShopButton
@onready var progression_button: Button = $ProgressionButton
@onready var settings_button: Button = $SettingsButton
@onready var exit_button: Button = $ExitButton


func _ready() -> void:
	play_button.pressed.connect(GameManager.switch_to_world_selection)
	progression_button.pressed.connect(GameManager.switch_to_progression)
	exit_button.pressed.connect(GameManager.exit_game)
