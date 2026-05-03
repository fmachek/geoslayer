class_name StatPointDropBody
extends Node2D
## Represents the body of a [StatPointDrop]. It is a rotating triangle.

## Fill color of the triangular shape.
@export var draw_color: Color
## Outline color of the triangular shape.
@export var outline_color: Color

## Speed at which the shape rotates every frame.
var rot_speed: float = 3.0

@onready var _area: Area2D = get_node("Area2D")
@onready var _col_polygon: CollisionPolygon2D = _area.get_node("CollisionPolygon2D")


func _process(delta: float) -> void:
	global_rotation += rot_speed * delta


func _draw() -> void:
	var polygon: PackedVector2Array = _col_polygon.polygon
	draw_colored_polygon(polygon, draw_color)
	polygon.append(polygon[0])
	draw_polyline(polygon, outline_color, 4)
