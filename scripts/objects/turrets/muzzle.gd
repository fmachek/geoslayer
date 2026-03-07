class_name Muzzle
extends Node2D

func _draw():
	var width = $Area2D/CollisionShape2D.shape.size.x
	var height = $Area2D/CollisionShape2D.shape.size.y
	draw_rect(Rect2(-width/2, -height/2, width, height), get_parent().draw_color)
	draw_rect(Rect2(-width/2, -height/2, width, height), get_parent().outline_color, false, 4)
