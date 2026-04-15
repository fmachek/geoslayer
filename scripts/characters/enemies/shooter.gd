class_name Shooter
extends Enemy
## Represents an enemy who casts [Shoot] and [Angleshot].


func _load_abilities() -> void:
	_load_ability(Shoot.new())
	var angleshot := Angleshot.new()
	angleshot.cooldown = 1.5
	_load_ability(angleshot)
