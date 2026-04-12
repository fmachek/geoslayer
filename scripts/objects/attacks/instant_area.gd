@abstract class_name InstantArea
extends Node2D
## Represents a circle which instantly does something to [Character]s
## standing inside of it, and then fades out.
##
## The action is performed automatically when entering the scene tree,
## however it always skips one physics frame, because on the first frame,
## [member Area2D.get_overlapping_bodies] returns an empty [Array].
## The [Array] needs to update first so that it can be used
## when doing something to the [Character]s standing inside the [Area2D].

## Emitted when [member radius] changes.
signal radius_changed(new_radius: float)
## Emitted when a detected body has been handled.
signal handled_body(body: Node2D)

## Source of the [InstantArea], for example a [Character] who cast an ability
## which spawned it.
var source: Node2D = null
## Radius of the [InstantArea].
var radius: float = 120.0: set = _set_radius
## Fill color of the [InstantArea].
var draw_color: Color = Color(0.0, 0.735, 0.0, 0.3)
## Outline color of the [InstantArea].
var outline_color: Color = Color(0.0, 0.582, 0.0, 0.3)

var _fade_tween: Tween
var _current_physics_frame: int = 0
var _performed: bool = false

@onready var _area: Area2D = $Area2D
@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D


@abstract func _perform(body: Node2D) -> void


@abstract func _update_area_mask(source: Node2D) -> void


func _ready() -> void:
	_update_shape_radius(radius)
	_update_area_mask(source)
	radius_changed.connect(_update_shape_radius)
	_fade_out()


func _physics_process(delta: float) -> void:
	if _performed:
		return
	_current_physics_frame += 1
	if _current_physics_frame == 2:
		_performed = true
		_handle_bodies()


func _handle_bodies() -> void:
	var bodies: Array[Node2D] = _area.get_overlapping_bodies()
	for body in bodies:
		_perform(body)
		handled_body.emit(body)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: float = radius / 24
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


func _fade_out() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0, 0.25)
	_fade_tween.tween_callback(queue_free)


func _set_radius(value: float) -> void:
	if value < 0:
		value = 0
	radius = value
	radius_changed.emit(value)


func _update_shape_radius(new_radius: float) -> void:
	if _col_shape:
		if _col_shape.shape:
			if not _col_shape.shape is CircleShape2D:
				_col_shape.shape = CircleShape2D.new()
			_col_shape.shape.radius = new_radius
		else:
			_col_shape.shape = CircleShape2D.new()
			_col_shape.shape.radius = new_radius
