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
## Methods such as [method _start_phase_1] must be implemented
## by each specific [Boss]. For example, a phase 2 method can add more abilities 
## to the [Boss]' kit, or make something special happen.

var _current_phase: int = 1


## Starts phase 1. Must be implemented by each specific [Boss].
@abstract func _start_phase_1() -> void
## Starts phase 2. Must be implemented by each specific [Boss].
@abstract func _start_phase_2() -> void
## Starts phase 3. Must be implemented by each specific [Boss].
@abstract func _start_phase_3() -> void


func _ready() -> void:
	super()
	is_immune_to_knockback = true
	health_changed.connect(_on_health_changed)
	_start_phase_1()


func _draw() -> void:
	_draw_spikes()
	super()


func _draw_spikes() -> void:
	var spike_amount: int = 10
	for i in range(spike_amount):
		var rot: float = (TAU / spike_amount) * i
		
		var radius: float = get_node("CollisionShape2D").shape.radius
		var poly_center := Vector2(radius - 5.0, 0).rotated(rot)
		var top := poly_center + (Vector2(20, 0).rotated(rot))
		var left := poly_center + Vector2.from_angle(rot + deg_to_rad(-90)) * 20
		var right := poly_center + Vector2.from_angle(rot + deg_to_rad(90)) * 20
		var points := [left, top, right]
		
		draw_colored_polygon(points, draw_color)
		points.append(left)
		draw_polyline(points, outline_color, 4)


func _switch_phase(new_phase: int) -> void:
	if _current_phase != new_phase and new_phase > _current_phase:
		_current_phase = new_phase
		if _current_phase == 2:
			_start_phase_2()
		elif _current_phase == 3:
			_start_phase_3()


func _on_health_changed(_old_health: int, new_health: int) -> void:
	if new_health <= (health.max_value / 3):
		_switch_phase(3)
	elif new_health <= (health.max_value / 3) * 2:
		_switch_phase(2)
