class_name StunProjectile
extends Projectile
## Represents a projectile which stuns [Character]s on hit.

## The stun duration in seconds.
var stun_duration: float = 2.0


func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_deal_damage(character)
	character.stun(stun_duration)
	explode()
