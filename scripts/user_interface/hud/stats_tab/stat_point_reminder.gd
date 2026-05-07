class_name StatPointReminder
extends HBoxContainer

var _arrow_y_movement: float = 6.0
var _arrow_move_time: float = 0.3
var _original_arrow_pos: Vector2
var _arrow_tween: Tween

@onready var _arrow: TextureRect = get_node("Arrow")
@onready var _label: Label = get_node("Label")


func _ready() -> void:
	_original_arrow_pos = _arrow.position
	show_reminder()


func show_reminder() -> void:
	show()
	_move_arrow_down()


func hide_reminder() -> void:
	hide()
	if _arrow_tween:
		_arrow_tween.kill()


func _move_arrow_down() -> void:
	_arrow_tween = _create_arrow_tween()
	_arrow.position = _original_arrow_pos - Vector2(0, _arrow_y_movement)
	var final_pos := _original_arrow_pos + Vector2(0, _arrow_y_movement)
	_arrow_tween.tween_property(_arrow, "position", final_pos, _arrow_move_time)
	_arrow_tween.tween_callback(_move_arrow_up)


func _move_arrow_up() -> void:
	_arrow_tween = _create_arrow_tween()
	var final_pos := _original_arrow_pos - Vector2(0, _arrow_y_movement)
	_arrow_tween.tween_property(_arrow, "position", final_pos, _arrow_move_time)
	_arrow_tween.tween_callback(_move_arrow_down)


func _create_arrow_tween() -> Tween:
	if _arrow_tween:
		_arrow_tween.kill()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	return tween


func _on_stats_tab_gained_stat_points() -> void:
	show_reminder()


func _on_stats_tab_pressed_increase() -> void:
	hide_reminder()
