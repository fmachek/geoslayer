class_name Spammer
extends Enemy

## Represents an enemy who casts [Shoot] and [Wideshot].

func load_abilities() -> void:
	load_ability(Flurry.new())
	load_ability(Wideshot.new())
