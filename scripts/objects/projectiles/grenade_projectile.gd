class_name GrenadeProjectile
extends Projectile

## Represents a projectile spawned by a [Grenade] after exploding.

## Node which caused the explosion of the [Grenade] ([member Grenade.explosion_body]).
var explosion_body: Node2D = null

func handle_character_collision(character: Character) -> void:
	# Prevent the small projectiles from all hitting the original target
	if character != explosion_body:
		explode_on_character(character)

## Deals damage to a [param character] and explodes.
func explode_on_character(character: Character) -> void:
	can_deal_damage = false
	deal_damage(character)
	explode()
