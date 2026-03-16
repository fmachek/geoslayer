class_name Swarmer
extends Enemy

## Represents an enemy who casts [Blast].

func load_abilities() -> void:
	load_ability(Blast.new())
