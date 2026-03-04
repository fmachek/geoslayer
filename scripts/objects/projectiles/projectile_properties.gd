class_name ProjectileProperties
extends RefCounted

var draw_color: Color
var outline_color: Color
var direction: Vector2
var speed: int
var source: Node2D
var damage: int
var radius: int
var start_pos: Vector2

func _init(draw_color: Color, outline_color: Color, direction: Vector2, speed: int, source: Node2D, damage: int, radius: int, start_pos: Vector2) -> void:
	self.draw_color = draw_color
	self.outline_color = outline_color
	self.direction = direction
	self.speed = speed
	self.source = source
	self.damage = damage
	self.radius = radius
	self.start_pos = start_pos
