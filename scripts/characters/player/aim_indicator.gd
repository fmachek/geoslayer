class_name AimIndicator
extends Node2D

## Represents a small indicator which rotates based on where the [PlayerCharacter]
## is currently aiming.

var draw_color: Color ## Color of the [AimIndicator].

func _draw():
	var radius: int = 6
	draw_circle(Vector2.ZERO, radius, draw_color)

## Changes [member AimIndicator.draw_color] when [member PlayerCharacter.outline_color]
## changes. This is connected inside the [PlayerCharacter] scene.
func _on_player_character_outline_color_changed(outline_color: Color) -> void:
	draw_color = outline_color
	queue_redraw()

## Changes [member AimIndicator.draw_color] when the [PlayerCharacter] is ready.
## This assumes that the [AimIndicator] is a child of a [PlayerCharacter].
func _on_player_character_ready() -> void:
	draw_color = get_parent().outline_color
	queue_redraw()
