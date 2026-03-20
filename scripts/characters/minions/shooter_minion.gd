class_name ShooterMinion
extends Minion
## Represents a [Minion] who casts [Shoot].


func _load_abilities() -> void:
	_load_ability(Shoot.new())
