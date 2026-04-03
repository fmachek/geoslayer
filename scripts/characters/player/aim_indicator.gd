class_name AimIndicator
extends Node2D
## Represents a small indicator which rotates based on where
## the [PlayerCharacter] is currently aiming.

var draw_color: Color ## Color of the [AimIndicator].
var radius: int = 4 ## Radius of the [AimIndicator].


func _draw():
	draw_circle(Vector2.ZERO, radius, draw_color, true, -1.0, true)


# Changes draw_color when the PlayerCharacter's outline_color
# changes. This is connected inside the PlayerCharacter scene.
func _on_player_character_outline_color_changed(outline_color: Color) -> void:
	draw_color = outline_color
	queue_redraw()


# Changes draw_color when the PlayerCharacter is ready.
# This assumes that the AimIndicator is a child of a PlayerCharacter.
func _on_player_character_ready() -> void:
	draw_color = get_parent().outline_color
	queue_redraw()
