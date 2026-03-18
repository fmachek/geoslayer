class_name Swarmer
extends Enemy

## Represents an enemy who casts [Blast].

func _load_abilities() -> void:
	_load_ability(Blast.new())
