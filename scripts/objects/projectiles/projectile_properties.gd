class_name ProjectileProperties
extends RefCounted
## This class contains properties which all [Projectile] objects require.
##
## All of the properties are set when instantiating the class via the constructor.

## Fill color of the [Projectile] shape.
var draw_color: Color
## Outline color of the [Projectile] shape.
var outline_color: Color
## Direction in which the [Projectile] is traveling.
var direction: Vector2
## Speed at which the [Projectile] is traveling.
var speed: float
## The node which is ignored during collisions (usually the caster).
var source: Node2D
## Damage dealt by the [Projectile].
var damage: int
## Radius of the [CircleShape2D] which is a child of [Projectile].
var radius: int
## Position at which the [Projectile] should spawn.
var start_pos: Vector2


func _init(draw_color: Color, outline_color: Color, direction: Vector2,
		speed: float, source: Node2D, damage: int, radius: int, start_pos: Vector2) -> void:
	self.draw_color = draw_color
	self.outline_color = outline_color
	self.direction = direction
	self.speed = speed
	self.source = source
	self.damage = damage
	self.radius = radius
	self.start_pos = start_pos
