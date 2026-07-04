class_name Dash
extends RefCounted

signal ended()

var distance: float
var duration: float
var direction: Vector2
var decrease_per_sec: float
var distance_remaining: float: set = _set_distance_remaining

var has_ended: bool = false


func _init(dash_distance: float, dash_duration: float, dash_direction: Vector2) -> void:
	self.distance = dash_distance
	self.duration = dash_duration
	self.direction = dash_direction
	decrease_per_sec = distance / duration
	distance_remaining = distance


func handle_process(delta: float) -> Vector2:
	var decrease: float = decrease_per_sec * delta
	
	var movement: Vector2
	
	if decrease > distance_remaining:
		movement = direction * distance_remaining
		distance_remaining -= decrease
		if not has_ended:
			has_ended = true
			ended.emit()
		return movement

	movement = direction * decrease
	distance_remaining -= decrease
	return movement


func interrupt() -> void:
	distance_remaining = 0
	has_ended = true
	ended.emit()


func _set_distance_remaining(value: float) -> void:
	if value < 0:
		distance_remaining = 0
	else:
		distance_remaining = value
