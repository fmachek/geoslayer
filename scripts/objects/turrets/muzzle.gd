class_name Muzzle
extends Node2D

var recoil_tween: Tween
var original_pos: Vector2
	
func _draw():
	var width = $Area2D/CollisionShape2D.shape.size.x
	var height = $Area2D/CollisionShape2D.shape.size.y
	draw_rect(Rect2(-width/2, -height/2, width, height), get_parent().draw_color)
	draw_rect(Rect2(-width/2, -height/2, width, height), get_parent().outline_color, false, 4)

func apply_recoil() -> void:
	if not original_pos:
		original_pos = position
	if recoil_tween:
		recoil_tween.kill()
	var recoil := Vector2(0, 25.0)
	var recoil_pos: Vector2 = (position + recoil)
	position = recoil_pos
	recoil_tween = get_tree().create_tween()
	recoil_tween.tween_property(self, "position", original_pos, 0.15)
	recoil_tween.play()
