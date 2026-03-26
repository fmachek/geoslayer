class_name LaserCross
extends Node2D
## Represents a rotating set of 4 [Laser]s each aiming in a different
## direction.

## Speed at which the [LaserCross] rotates every physics frame.
var rot_speed: float = 0.75
## The [Node2D] which the [Laser] originated from. For example, it could be
## a [Character] who casted an ability which spawned the [LaserCross].
var source: Node2D: set = _set_source
## Damage dealt by the [Laser]s.
var damage: int: set = _set_damage
## Time before the [LaserCross] disappears.
var lifetime: float:
	set(value):
		lifetime = value
		if _free_timer:
			_free_timer.wait_time = lifetime

@onready var _free_timer: Timer = $FreeTimer


func _ready() -> void:
	_free_timer.wait_time = lifetime
	_free_timer.start()


func _physics_process(delta: float) -> void:
	global_rotation += rot_speed * delta


func _on_free_timer_timeout() -> void:
	var children = get_children()
	var lasers: Array[Laser] = _get_lasers()
	for laser in lasers:
		laser.disappear()


func _get_lasers() -> Array[Laser]:
	var lasers: Array[Laser] = []
	var children = get_children()
	for child in children:
		if child is Laser:
			lasers.append(child)
	return lasers


#region setters
func _set_source(value: Node2D) -> void:
	source = value
	var lasers: Array[Laser] = _get_lasers()
	for laser in lasers:
		laser.source = value


func _set_damage(value: int) -> void:
	damage = value
	var lasers: Array[Laser] = _get_lasers()
	for laser in lasers:
		laser.damage = value
#endregion
