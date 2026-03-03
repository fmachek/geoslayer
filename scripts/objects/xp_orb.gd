class_name XPOrb
extends Node2D

@export var draw_color: Color = Color(1.0, 0.0, 1.0, 1.0)
@export var outline_color: Color = Color(0.732, 0.0, 0.732, 1.0)

@export var xp_amount: int = 10

func _draw():
	var radius = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		body.pick_up_xp_orb(self)
		var xp_orb_particles: XPOrbParticles = load("res://scenes/particle_effects/xp_orb_particles.tscn").instantiate()
		xp_orb_particles.load_from_orb(self)
		queue_free()
