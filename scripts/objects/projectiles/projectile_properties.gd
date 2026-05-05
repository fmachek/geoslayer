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


func _init(proj_draw_color: Color, proj_outline_color: Color, proj_direction: Vector2,
		proj_speed: float, proj_source: Node2D, proj_damage: int, proj_radius: int,
		proj_start_pos: Vector2) -> void:
	self.draw_color = proj_draw_color
	self.outline_color = proj_outline_color
	self.direction = proj_direction
	self.speed = proj_speed
	self.source = proj_source
	self.damage = proj_damage
	self.radius = proj_radius
	self.start_pos = proj_start_pos
