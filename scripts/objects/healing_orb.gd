class_name HealingOrb
extends Node2D

@export var draw_color: Color = Color(0.257, 0.742, 0.0, 1.0)
@export var outline_color: Color = Color(0.162, 0.499, 0.0, 1.0)

func _draw():
	var radius = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		var health: Health = body.health
		health.add_value(health.max_value_after_buffs)
		queue_free()
