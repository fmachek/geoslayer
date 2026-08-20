class_name StatPointPopup
extends VBoxContainer

var _fade_tween: Tween

@onready var _fade_out_timer: Timer = $FadeOutTimer


func _ready():
	# If the user gains a stat point mid-game, it 100%
	# came from a stat point drop.
	UserManager.added_stat_point.connect(show_popup)


func show_popup():
	if _fade_tween:
		_fade_tween.kill()
	show()
	modulate.a = 1.0
	_fade_out_timer.stop()
	_fade_out_timer.start()


func _fade_out():
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	_fade_tween.tween_callback(hide)


func _on_fade_out_timer_timeout() -> void:
	_fade_out()
