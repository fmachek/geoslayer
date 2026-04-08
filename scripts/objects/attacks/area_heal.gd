class_name AreaHeal
extends Node2D
## Represents a circle which instantly heals [Character]s standing inside of it,
## and then fades out.
##
## The heal is performed automatically when entering the scene tree,
## however it always skips one physics frame, because on the first frame,
## [member Area2D.get_overlapping_bodies] returns an empty [Array].
## The [Array] needs to update first so that it can be used
## when healing the [Character]s standing inside the [Area2D].

## Emitted when [member radius] changes.
signal radius_changed(new_radius: float)

const _HEAL_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/heal_label.tscn")

## Source of the [AreaHeal], for example a [Character] who cast an ability
## which spawned it.
var source: Node2D = null
## Amount for which [Character]s are healed.
var heal_amount: int = 10
## Radius of the [AreaHeal].
var radius: float = 120.0: set = _set_radius
## Fill color of the [AreaHeal].
var draw_color: Color = Color(0.0, 0.735, 0.0, 0.3)
## Outline color of the [AreaHeal].
var outline_color: Color = Color(0.0, 0.582, 0.0, 0.3)

var _fade_tween: Tween
var _current_physics_frame: int = 0
var _healed: bool = false

@onready var _area: Area2D = $Area2D
@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	_update_shape_radius(radius)
	_update_area_mask(source)
	radius_changed.connect(_update_shape_radius)
	_fade_out()


func _physics_process(delta: float) -> void:
	if _healed:
		return
	_current_physics_frame += 1
	if _current_physics_frame == 2:
		_healed = true
		_perform_heal()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: float = radius / 24
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


func _perform_heal() -> void:
	var bodies: Array[Node2D] = _area.get_overlapping_bodies()
	for body in bodies:
		if body is Character:
			body.heal(heal_amount)
			_spawn_heal_label(heal_amount, body.global_position)


func _fade_out() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0, 0.25)
	_fade_tween.tween_callback(queue_free)


func _spawn_heal_label(amount: int, pos: Vector2) -> void:
	var heal_label: DamageLabel = _HEAL_LABEL_SCENE.instantiate()
	get_parent().add_child(heal_label)
	heal_label.load_damage(amount, pos)
	heal_label.play_tween()


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


func _update_area_mask(source: Node2D) -> void:
	CollisionMaskFunctions.set_friendly_area_collision_mask(_area, source)
