class_name ProjectileParticles
extends CPUParticles2D

func _on_finished() -> void:
	queue_free()

func load_from_projectile(projectile: Projectile):
	projectile.get_parent().add_child(self)
	global_position = projectile.global_position
	color = projectile.draw_color
	scale_amount_min = projectile.projectile_radius*0.8
	scale_amount_max = scale_amount_min*1.5
	amount = projectile.projectile_radius
	emitting = true
