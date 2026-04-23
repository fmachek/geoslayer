class_name DamageLabel
extends Label
## Represents a label displaying the amount of damage dealt, or heal amount.

var _tween: Tween


## Plays a fade out and move effect, then calls [method queue_free].
func play_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "global_position", global_position + Vector2(0, -10), 0.75)
	_tween.parallel().tween_property(self, "modulate:a", 0, 0.75)
	_tween.tween_callback(queue_free)


## Loads the label. It will display the given [param amount] and it will move to
## a given [param pos]. The [param type] and [param char] determines
## what the label looks like, mainly the font color, but also size.
func load_label(amount: int, pos: Vector2, type: Character.DamageType, char: Character) -> void:
	text = str(amount)
	global_position = pos
	_load_label_type(type, char)


func _load_label_type(type: Character.DamageType, char: Character) -> void:
	_load_label_settings()
	match type:
		Character.DamageType.NORMAL:
			if char is PlayerCharacter or char is Minion:
				label_settings.font_color = Color.RED
			else:
				label_settings.font_color = Color.WHITE
		Character.DamageType.DOT:
			label_settings.font_size = 16
			if char is PlayerCharacter or char is Minion:
				label_settings.font_color = Color.RED
			else:
				label_settings.font_color = Color.WHITE
		Character.DamageType.HEAL:
			label_settings.font_color = Color.GREEN


func _load_label_settings() -> void:
	var settings := LabelSettings.new()
	settings.font_size = 22
	settings.outline_size = 8
	settings.outline_color = Color.BLACK
	label_settings = settings
