class_name Swarmer
extends Enemy

## Represents an enemy who casts [Blast].

func _load_abilities() -> void:
	var blast := Blast.new()
	blast.cooldown *= 3
	_load_ability(blast)
