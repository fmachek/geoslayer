class_name PiercingProjectile
extends Projectile
## Represents a projectile which pierces through [Character]s.

# Used to track collisions to prevent multiple collisions with one target.
var _collisions: Array[Character] = []


# Overrides the Projectile draw function. This projectile is special
# because while it has a circular collision shape, the drawn shape is
# a pointy bullet.
func _draw_projectile_shape() -> void:
	var radius: float = _col_shape.shape.radius
	var outline_width: float = radius / 8
	
	var rect := Rect2(Vector2(-radius, -radius), Vector2(radius * 2, radius * 2))
	draw_rect(rect, projectile_properties.draw_color, true)
	var pointy_part_points := [
			Vector2(radius, -radius),
			Vector2(radius, radius),
			Vector2(radius * 4, 0)
	]
	draw_colored_polygon(pointy_part_points, projectile_properties.draw_color)
	var outline_points := [
			Vector2(-radius, -radius),
			Vector2(radius, -radius),
			Vector2(radius * 4, 0),
			Vector2(radius, radius),
			Vector2(-radius, radius),
			Vector2(-radius, -radius)
	]
	draw_polyline(outline_points, projectile_properties.outline_color, outline_width, true)


# Overrides the Projectile character collision function. Unlike regular projectiles,
# it does not explode on impact, but pierces through characters.
func _handle_character_collision(character: Character) -> void:
	if not character in _collisions:
		_collisions.append(character)
		_deal_damage(character)
