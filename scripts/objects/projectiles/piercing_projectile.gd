class_name PiercingProjectile
extends Projectile

# Overries the Projectile draw function. This projectile is special
# because while it has a circular collision shape, the drawn shape is
# a pointy bullet.
func draw_projectile_shape() -> void:
	var radius = col_shape.shape.radius
	var outline_width = radius/8
	
	draw_rect(Rect2(Vector2(-radius, -radius), Vector2(radius*2, radius*2)), projectile_properties.draw_color, true)
	var pointy_part_points = [Vector2(radius, -radius), Vector2(radius, radius), Vector2(radius*4, 0)]
	draw_colored_polygon(pointy_part_points, projectile_properties.draw_color)
	var outline_points = [Vector2(-radius, -radius), Vector2(radius, -radius), Vector2(radius*4, 0), Vector2(radius, radius), Vector2(-radius, radius), Vector2(-radius, -radius)]
	draw_polyline(outline_points, projectile_properties.outline_color, outline_width, true)

# Overriding the Projectile collision function. Unlike regular projectiles,
# it does not explode on impact, but pierces through enemies.
func handle_character_collision(character: Character) -> void:
	deal_damage(character)
