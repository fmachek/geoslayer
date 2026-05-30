class_name AimIndicator
extends Node2D
## Represents a small indicator which rotates based on where
## the [Character] is currently aiming.

var draw_color: Color ## Color of the [AimIndicator].
var radius: int = 4 ## Radius of the [AimIndicator].


func _draw():
	draw_circle(Vector2.ZERO, radius, draw_color, true, -1.0, true)


func _on_character_outline_color_changed(outline_color: Color) -> void:
	draw_color = outline_color
	queue_redraw()


func _on_character_ready() -> void:
	draw_color = get_parent().outline_color
	queue_redraw()
