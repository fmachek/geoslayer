class_name Shooter
extends Enemy

## Represents an enemy who casts [Shoot].

func load_abilities() -> void:
	load_ability(Shoot.new())
