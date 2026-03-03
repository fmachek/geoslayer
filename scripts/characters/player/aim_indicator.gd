class_name AimIndicator
extends Node2D

var draw_color: Color

func _draw():
	var radius = 6
	draw_circle(Vector2.ZERO, radius, draw_color)

func _on_player_character_outline_color_changed(outline_color: Variant) -> void:
	draw_color = outline_color
	queue_redraw()

func _on_player_character_ready() -> void:
	draw_color = get_parent().outline_color
	queue_redraw()
