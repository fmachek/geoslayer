class_name Laser
extends Node2D
## Represents a laser which deals damage to [Character]s.
##
## The [Laser] has a [member laser_length]. However, if
## there is something blocking it, for example a wall, the
## [Laser] ends at the point where the collision occurs.

const _LABEL_PATH := "res://scenes/user_interface/world_labels/damage_label.tscn"
const _damage_label_scene := preload(_LABEL_PATH)

## Fill color of the [Laser].
@export var draw_color: Color = Color(1.0, 0.0, 0.0, 1.0)

## Length of the [Laser].
var laser_length: float = 2000.0
## Width of the [Laser].
var laser_width: float = 10.0
## The [Node2D] which the [Laser] originated from. For example, it could be
## a [Character] who casted an ability which spawned the [Laser].
var source: Node2D: set = _set_source
## Damage dealt by the [Laser] on every damage tick.
var damage: int = 10

var _target_pos: Vector2 = Vector2(laser_length, 0) # The laser end point.
var _can_deal_damage: bool = true:
	set(value):
		_can_deal_damage = value
		if not value:
			_damage_timer.stop()
var _fade_tween: Tween

@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D
# Used to time damage ticks.
@onready var _damage_timer: Timer = $DamageTimer


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size.x = laser_length
	shape.size.y = laser_width
	_col_shape.shape = shape
	_update_shape()


func _physics_process(delta: float) -> void:
	_update_shape()


func _draw() -> void:
	var laser_shape: RectangleShape2D = _col_shape.shape
	var size_x: float = laser_shape.size.x
	var size_y: float = laser_shape.size.y
	var rect_pos := Vector2(0, -size_y / 2)
	var rect_size := Vector2(size_x, size_y)
	var rect := Rect2(rect_pos, rect_size)
	draw_rect(rect, draw_color)


## Causes the [Laser] to fade out and free itself.
func disappear() -> void:
	_can_deal_damage = false
	_fade_out()


func _update_shape() -> void:
	var collision_point: Vector2 = _get_collision_with_wall(_target_pos)
	var size_x: float = collision_point.x
	
	var laser_shape: RectangleShape2D = _col_shape.shape
	laser_shape.size.x = size_x
	
	_col_shape.position = Vector2(size_x / 2, 0)
	queue_redraw()


func _get_collision_with_wall(target_pos: Vector2) -> Vector2:
	var raycast: RayCast2D = $RayCast2D
	raycast.target_position = target_pos
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var col_point: Vector2 = to_local(raycast.get_collision_point())
		return col_point
	return target_pos


func _update_collision_mask(source: Node2D) -> void:
	var area: Area2D = $Area2D
	CollisionMaskFunctions.set_area_collision_mask(area, source)


func _on_damage_timer_timeout() -> void:
	var area: Area2D = $Area2D
	var bodies: Array[Node2D] = area.get_overlapping_bodies()
	for body: Node2D in bodies:
		if body is Character:
			var damage_taken: int = body.take_damage(damage)
			_spawn_damage_label(damage_taken, body.global_position)


func _spawn_damage_label(damage: int, pos: Vector2) -> void:
	var damage_label: DamageLabel = _damage_label_scene.instantiate()
	WorldManager.current_world.add_child(damage_label)
	var random_offset := Vector2(randf_range(-5, 5), randf_range(-5, 5))
	damage_label.load_damage(damage, pos + random_offset)
	damage_label.play_tween()


func _on_start_timer_timeout() -> void:
	_damage_timer.start()


func _fade_out() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0, 0.5)
	_fade_tween.tween_callback(queue_free)


func _set_source(value: Node2D) -> void:
	source = value
	if source is Character:
		draw_color = source.draw_color
	call_deferred("_update_collision_mask", source)
