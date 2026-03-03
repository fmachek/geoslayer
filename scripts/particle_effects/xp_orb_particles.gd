class_name XPOrbParticles
extends CPUParticles2D

func _on_finished() -> void:
	queue_free()

func load_from_orb(orb: XPOrb):
	orb.get_parent().add_child(self)
	global_position = orb.global_position
	color = orb.draw_color
	emitting = true
