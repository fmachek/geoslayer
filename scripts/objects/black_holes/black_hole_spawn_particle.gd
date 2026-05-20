class_name BlackHoleSpawnParticle
extends Node2D

signal reached_center()

var draw_color: Color = Color.BLACK
var radius: float
var movement_duration: float = 0.5

var _pos_tween: Tween
var _alpha_tween: Tween


func _ready() -> void:
	reached_center.connect(queue_free)
	_set_random_radius()
	_fade_in()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, draw_color)


func move_to_center(start_pos: Vector2, final_pos: Vector2) -> void:
	if _pos_tween:
		_pos_tween.kill()
	position = start_pos
	_pos_tween = create_tween()
	_pos_tween.tween_property(self, "position", final_pos, movement_duration)
	_pos_tween.tween_callback(reached_center.emit)


func _fade_in() -> void:
	if _alpha_tween:
		_alpha_tween.kill()
	_alpha_tween = create_tween()
	self_modulate.a = 0.0
	var fade_duration: float = movement_duration / 2
	_alpha_tween.tween_property(self, "self_modulate:a", 1.0, fade_duration)


func _set_random_radius() -> void:
	radius = randf_range(15.0, 20.0)
	queue_redraw()
