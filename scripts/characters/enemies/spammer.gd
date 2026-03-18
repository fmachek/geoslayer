class_name Spammer
extends Enemy

## Represents an enemy who casts [Shoot] and [Wideshot].

func _load_abilities() -> void:
	_load_ability(Flurry.new())
	_load_ability(Wideshot.new())
