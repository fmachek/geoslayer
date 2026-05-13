class_name ShooterMinion
extends Minion
## Represents a [Minion] who casts [Shoot].


func _load_abilities() -> void:
	var shoot := Shoot.new()
	shoot.projectile_knockback = 0.0
	_load_ability(shoot)
