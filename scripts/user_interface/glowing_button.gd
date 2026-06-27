class_name GlowingButton
extends Button

var highlight_fade_time: float = 0.5
var _highlight_tween: Tween
@onready var _highlight_panel: Panel = get_node("HighlightPanel")


func _ready() -> void:
	mouse_entered.connect(_hide_highlight)
	mouse_exited.connect(func(): if visible: _show_highlight())
	_show_highlight()


func _show_highlight() -> void:
	_highlight_fade_in()


func _hide_highlight() -> void:
	if _highlight_tween:
		_highlight_tween.kill()
	_highlight_panel.modulate.a = 0


func _highlight_fade_in():
	if _highlight_tween:
		_highlight_tween.kill()
	_highlight_panel.modulate.a = 0
	_highlight_tween = create_tween()
	_highlight_tween.tween_property(_highlight_panel, "modulate:a", 1, highlight_fade_time)
	_highlight_tween.tween_callback(_highlight_fade_out)


func _highlight_fade_out():
	if _highlight_tween:
		_highlight_tween.kill()
	_highlight_tween = create_tween()
	_highlight_tween.tween_property(_highlight_panel, "modulate:a", 0, highlight_fade_time)
	_highlight_tween.tween_callback(_highlight_fade_in)
