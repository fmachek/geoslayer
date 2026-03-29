class_name Shooter
extends Enemy

## Represents an enemy who casts [Shoot] and [Angleshot].

func _load_abilities() -> void:
	_load_ability(Shoot.new())
	_load_ability(Angleshot.new())
