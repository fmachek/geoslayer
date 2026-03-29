@abstract class_name Boss
extends Enemy
## Represents a boss [Enemy].
##
## A [Boss] has a lot of health and deals a lot of damage.
##
## It has 3 phases. The first phase begins immediately upon entering
## the scene tree. The second phase begins when the [Boss] health drops by
## a third. The last phase begins when the [Boss] health drops by another third
## of the max health.[br][br]
##
## Methods such as [member _start_phase_1] must be implemented
## by each specific [Boss]. For example, a phase 2 method can add more abilities 
## to the [Boss]' kit, or make something special happen.

var _current_phase: int = 1


@abstract func _start_phase_1() -> void
@abstract func _start_phase_2() -> void
@abstract func _start_phase_3() -> void


func _ready() -> void:
	super()
	health_changed.connect(_on_health_changed)
	_start_phase_1()


func _on_health_changed(old_health: int, new_health: int) -> void:
	if new_health <= (health.max_value / 3):
		_switch_phase(3)
	elif new_health <= (health.max_value / 3) * 2:
		_switch_phase(2)


func _switch_phase(new_phase: int) -> void:
	if _current_phase != new_phase and new_phase > _current_phase:
		_current_phase = new_phase
		if _current_phase == 2:
			_start_phase_2()
		elif _current_phase == 3:
			_start_phase_3()
