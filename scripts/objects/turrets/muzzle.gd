class_name Muzzle
extends Node2D

## Represents a turret's muzzle.
##
## Plays a recoil visual effect when the [Turret] shoots.

# Used to play the recoil visual effect
var _recoil_tween: Tween
# Original position of the muzzle before any tweens
var _original_pos: Vector2


func _draw():
	var col_shape: CollisionShape2D = $Area2D/CollisionShape2D
	var width: int = col_shape.shape.size.x
	var height: int = col_shape.shape.size.y
	var rect := Rect2(-width/2, -height/2, width, height)
	var turret_draw_color: Color = get_parent().draw_color
	var turret_outline_color: Color = get_parent().outline_color
	draw_rect(rect, turret_draw_color)
	draw_rect(rect, turret_outline_color, false, 4)


## Plays the recoil visual effect.
func apply_recoil() -> void:
	if not _original_pos:
		_original_pos = position
	if _recoil_tween:
		_recoil_tween.kill()
	var recoil := Vector2(0, 25.0)
	var recoil_pos: Vector2 = (position + recoil)
	position = recoil_pos
	_recoil_tween = get_tree().create_tween()
	_recoil_tween.tween_property(self, "position", _original_pos, 0.15)
	_recoil_tween.play()
