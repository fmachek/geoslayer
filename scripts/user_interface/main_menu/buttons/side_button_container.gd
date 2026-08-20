class_name SideButtonContainer
extends VBoxContainer

@onready var credits_button: Button = %CreditsButton


func _ready() -> void:
	credits_button.pressed.connect(GameManager.switch_to_credits)
