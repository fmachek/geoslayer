class_name DoTProjectile
extends Projectile
## Special type of [Projectile] which applies a [DamageOverTime]
## effect to a [Character] on impact.

## The DoT effect applied to a [Character] when hit.
var dot: DamageOverTime


func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_deal_damage(character)
	_apply_dot(character)
	explode()


func _apply_dot(target: Character) -> void:
	if not dot:
		return
	dot.apply_to(target)


func _update_particle_size(projectile_radius: int) -> void:
	var particles: CPUParticles2D = %FlyingParticles
	particles.scale_amount_min = float(projectile_radius) / 500
	particles.scale_amount_max = particles.scale_amount_min * 2
