class_name BuffPickupLabel
extends Label

var _tween: Tween


func play_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", position + Vector2(0, -45), 2)
	_tween.parallel().tween_property(self, "modulate:a", 0, 2)
	_tween.tween_callback(queue_free)


func load_buff(buff: Buff) -> void:
	label_settings = LabelSettings.new()
	var symbol: String
	if buff.amount >= 0:
		symbol = "+"
		label_settings.font_color = Color.GREEN
	else:
		symbol = "-"
		label_settings.font_color = Color.RED
	label_settings.outline_color = Color.BLACK
	label_settings.outline_size = 8
	text = symbol + str(buff.amount) + " " + buff.target_stat.stat_name \
	 		+ " for " + str(buff.duration) + " seconds!"
