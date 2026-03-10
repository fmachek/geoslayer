class_name WorldSelectionButton
extends Button

@export var world_number: int

func _ready() -> void:
	text = str(world_number)

func change_world_number(new_number: int) -> void:
	world_number = new_number
	text = str(world_number)
