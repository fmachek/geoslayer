class_name XPLabel
extends Label

var time_until_fade: float = 0.5
var fade_time: float = 1.0
var y_movement: float = 30.0

var rand_offset_range: float = 50.0

var _alpha_tween: Tween
var _pos_tween: Tween


func spawn_at(char: Character, xp_amount: int) -> void:
	text = "+%d XP" % xp_amount
	var rand_offset_x: float = randf_range(-rand_offset_range, rand_offset_range)
	var rand_offset_y: float = randf_range(-rand_offset_range, rand_offset_range)
	char.add_child(self)
	global_position = (char.global_position + Vector2(rand_offset_x, rand_offset_y)) - \
			Vector2(size.x / 2, size.y / 2)
	_play_tweens()


func _play_tweens() -> void:
	_play_pos_tween()
	_play_alpha_tween()


func _play_pos_tween() -> void:
	if _pos_tween:
		_pos_tween.kill()
	_pos_tween = create_tween()
	var final_pos: Vector2 = position - Vector2(0, y_movement)
	var total_time: float = time_until_fade + fade_time
	_pos_tween.tween_property(self, "position", final_pos, total_time)


func _play_alpha_tween() -> void:
	if _alpha_tween:
		_alpha_tween.kill()
	await get_tree().create_timer(time_until_fade).timeout
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 0.0, fade_time)
	_alpha_tween.tween_callback(queue_free)
