class_name Shooter
extends Enemy

## Represents an enemy who casts [Shoot].

func _load_abilities() -> void:
	_load_ability(Shoot.new())
