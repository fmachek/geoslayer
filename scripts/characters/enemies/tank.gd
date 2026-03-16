class_name Tank
extends Enemy

## Represents an enemy who casts [Cannonball].

func load_abilities() -> void:
	load_ability(Cannonball.new())
