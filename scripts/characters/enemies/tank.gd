class_name Tank
extends Enemy

## Represents an enemy who casts [Cannonball].

func _load_abilities() -> void:
	_load_ability(Cannonball.new())
