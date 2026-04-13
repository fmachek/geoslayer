class_name SmashArea
extends InstantDamageArea
## Represents an [InstantDamageArea] which also stuns and applies
## knockback to [Character]s. It is used by the [Smash] ability.

## Duration of the stun applied to [Character]s.
var stun_duration: float = 2.0
## Amount of knockback applied to [Character]s.
var knockback: float = 500.0


func _ready() -> void:
	super()
	# Connect to handled_body to do additional things
	handled_body.connect(_stun_character)
	handled_body.connect(_apply_knockback)


func _apply_knockback(body: Node2D) -> void:
	if body is Character:
		var direction: Vector2 = global_position.direction_to(body.global_position)
		body.apply_knockback(knockback * direction)


func _stun_character(body: Node2D) -> void:
	if body is Character:
		body.stun(stun_duration)
