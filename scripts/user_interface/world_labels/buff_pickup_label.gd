class_name BuffPickupLabel
extends Label

var tween: Tween

func play_tween() -> void:
	tween = create_tween()
	tween.tween_property(self, "global_position", global_position + Vector2(0, -25), 2)
	tween.parallel().tween_property(self, "modulate:a", 0, 2)
	tween.tween_callback(queue_free)

func load_buff(buff: Buff) -> void:
	label_settings = LabelSettings.new()
	var symbol: String
	if buff.amount >= 0:
		symbol = "+"
		label_settings.font_color = Color.GREEN
	else:
		label_settings.font_color = Color.RED
	label_settings.outline_color = Color.BLACK
	label_settings.outline_size = 8
	text = symbol + str(buff.amount) + " " + buff.target_stat.stat_name + " for " + str(buff.duration) + " seconds!"
