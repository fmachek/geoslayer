class_name UnlocksContainer
extends PanelContainer

@onready var _unlock_row_container: VBoxContainer = $MarginContainer/UnlockRowContainer

func _on_next_world_unlock_hidden() -> void:
	_check_children()


func _check_children() -> void:
	var children = _unlock_row_container.get_children()
	var is_any_child_visible: bool = false
	for child in children:
		if child.visible:
			is_any_child_visible = true
			break
	if not is_any_child_visible:
		hide()
