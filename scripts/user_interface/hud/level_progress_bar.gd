class_name LevelProgressBar
extends ProgressBar

@onready var xp_label: Label = get_node("XPLabel")


func _ready() -> void:
	value_changed.connect(_update_label)
	_update_label(value)


func _update_label(new_value: float) -> void:
	xp_label.text = "%d/%d" % [new_value, max_value]
