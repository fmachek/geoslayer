class_name BuffPickupLabel
extends Label
## Represents a label which shows information about what [Buff]
## was applied by a [BuffPickup] and for how long.

var _tween: Tween


## Plays a fade out and move effect, then calls [method queue_free].
func play_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "global_position", global_position + Vector2(0, -25), 2)
	_tween.parallel().tween_property(self, "modulate:a", 0, 2)
	_tween.tween_callback(queue_free)


## Loads the [BuffPickupLabel] so that it says that the [param buff]
## was applied and for how long.
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
	text = "%s%d %s for %.2f seconds!" % [symbol, buff.amount, buff.target_stat.stat_name, buff.duration]
