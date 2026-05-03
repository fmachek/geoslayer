class_name Sentry
extends Enemy
## Represents an enemy who casts [Mirrorshot] and [Protect].


func _load_abilities() -> void:
	_load_ability(Mirrorshot.new())
	_load_ability(Protect.new())
