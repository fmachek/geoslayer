class_name GrenadeProjectile
extends Projectile

## Represents a projectile spawned by a [Grenade] after exploding.

# Node which caused the explosion of the [Grenade].
var _explosion_body: Node2D = null


func _handle_character_collision(character: Character) -> void:
	# Prevent the small projectiles from all hitting the original target
	if character != _explosion_body:
		_explode_on_character(character)


## Deals damage to a [param character] and explodes.
func _explode_on_character(character: Character) -> void:
	_can_deal_damage = false
	_deal_damage(character)
	explode()

## Sets [member GrenadeProjectile._explosion_body].
func set_explosion_body(body: Node2D) -> void:
	_explosion_body = body
