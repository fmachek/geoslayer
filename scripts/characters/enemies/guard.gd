class_name Guard
extends Enemy
## Represents a strong [Enemy] who casts [Coneshot] and [Fortify].


func _load_abilities() -> void:
	_load_ability(Coneshot.new())
	_load_ability(Fortify.new())
