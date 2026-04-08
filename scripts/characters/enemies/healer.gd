class_name Healer
extends Enemy
## Represents a healer [Enemy] who casts [Lifesteal] and
## [Heal].


func _load_abilities() -> void:
	_load_ability(Lifesteal.new())
	_load_ability(Heal.new())
