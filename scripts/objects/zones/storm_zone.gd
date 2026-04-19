class_name StormZone
extends DamagingZone
## Represents a zone which damages and slows [Character]s standing in it down.

## Speed debuff applied to the [Character] hit.
var speed_debuff: int = 100
## Duration of the speed debuff applied to the [Character] hit, in seconds.
var speed_debuff_duration: float = time_per_tick


func _apply_additional_effects(character: Character) -> void:
	_slow_character(character)


# Applies a speed debuff to the target.
func _slow_character(target: Character) -> void:
	var speed_debuff := Buff.new(-speed_debuff, speed_debuff_duration)
	speed_debuff.apply_to_stat(target.speed)
