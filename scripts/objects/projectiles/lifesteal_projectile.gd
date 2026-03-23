class_name LifestealProjectile
extends Projectile
## Special type of [Projectile] which deals damage to a [Character]
## on impact and heals the caster for a portion of the damage dealt.

const _HEAL_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/heal_label.tscn")


func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_deal_damage(character)
	var source: Node2D = projectile_properties.source
	if is_instance_valid(source):
		if source is Character:
			_heal_character(source)
	explode()


func _update_particle_size(projectile_radius: int) -> void:
	var particles: CPUParticles2D = %FlyingParticles
	particles.scale_amount_min = float(projectile_radius) / 10
	particles.scale_amount_max = particles.scale_amount_min * 2


func _heal_character(character: Character) -> void:
	var damage: int = projectile_properties.damage
	var heal_amount: int = damage / 4
	# Minimum heal amount is 1 if any damage is dealt
	if damage > 0 and heal_amount == 0:
		heal_amount = 1
	character.heal(heal_amount)
	var label_pos: Vector2 = character.global_position
	_spawn_heal_label(heal_amount, label_pos)


func _spawn_heal_label(amount: int, pos: Vector2) -> void:
	var heal_label: DamageLabel = _HEAL_LABEL_SCENE.instantiate()
	get_parent().add_child(heal_label)
	heal_label.load_damage(amount, pos)
	heal_label.play_tween()
