class_name SlowingProjectile
extends Projectile
## Represents a special [Projectile] which slows characters down
## on impact.

## Amount by which the speed of the [Character] who gets
## hit is reduced.
var speed_debuff: int = 100
## Duration for which the speed of the [Character] who gets
## hit is reduced.
var speed_debuff_duration: float = 0.75


func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_deal_damage(character)
	_apply_speed_debuff(character)
	explode()


func _apply_speed_debuff(character: Character) -> void:
	var debuff: Buff = Buff.new(-speed_debuff, speed_debuff_duration)
	debuff.apply_to_stat(character.speed)


func _update_particle_size(projectile_radius: int) -> void:
	var particles: CPUParticles2D = %FlyingParticles
	particles.scale_amount_min = float(projectile_radius) / 20
	particles.scale_amount_max = particles.scale_amount_min * 2
