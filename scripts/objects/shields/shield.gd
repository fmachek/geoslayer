class_name Shield
extends Node2D
## Represents a shield circle area which destroys incoming [Projectile]s.
## Each [Projectile] reduces the [member durability].
## The [Shield] disappears after [member expiration_time] passes or
## when [member durability] reaches 0.

## Emitted when [member radius] changes.
signal radius_changed(new_radius: float)
## Emitted when [member expiration_time] changes.
signal expiration_time_changed(new_time: float)
## Emitted when [member durability] changes.
signal durability_changed(new_durability: int)

## Fill color of the [Shield].
@export var draw_color := Color(0.565, 0.565, 0.565, 0.25)
## Outline color of the [Shield].
@export var outline_color := Color(0.431, 0.431, 0.431, 0.5)

## Radius of the [Shield]'s [CircleShape2D].
var radius: float = 82.0: set = _set_radius
## Time until the [Shield] expires, in seconds.
var expiration_time: float = 5.0: set = _set_expiration_time
## When it hits 0, the shield breaks.
var durability: int = 150: set = _set_durability
## Says if the [Shield] is active or not.
var is_active: bool = true
# Tween used for fade in and fade out.
var _fade_tween: Tween

@onready var _area: Area2D = $Area2D
@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _expiration_timer: Timer = $ExpirationTimer


func _ready() -> void:
	_area.area_entered.connect(_on_area_entered)
	radius_changed.connect(_update_shape_radius)
	durability_changed.connect(_on_durability_changed)
	_expiration_timer.timeout.connect(destroy)
	expiration_time_changed.connect(_update_expiration_timer)
	_update_shape_radius(radius)
	_update_expiration_timer(expiration_time)
	_update_colors()
	_expiration_timer.start()
	_fade_in()


func _draw() -> void:
	var outline_width: float = float(radius) / 16
	draw_circle(Vector2.ZERO, radius - outline_width / 2, draw_color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


## The [Shield] becomes inactive, fades out and disappears.
func destroy() -> void:
	if not is_active:
		return
	is_active = false
	_expiration_timer.stop()
	_stop_monitoring()
	_fade_out()


func _on_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if not parent:
		return
	if parent is Projectile:
		var projectile: Projectile = parent
		if _is_enemy_projectile(projectile):
			var damage: int = projectile.projectile_properties.damage
			projectile.explode()
			durability -= damage


func _on_durability_changed(new_value: int) -> void:
	if new_value == 0:
		destroy()


func _is_enemy_projectile(projectile: Projectile) -> bool:
	var parent = get_parent()
	if not parent:
		return true
	var parent_layer: int = 1
	if parent is PlayerCharacter:
		parent_layer = 10
	elif parent is Minion:
		parent_layer = 7
	elif parent is Enemy:
		parent_layer = 8
	var proj_area: Area2D = projectile.get_node("Area2D")
	return proj_area.get_collision_mask_value(parent_layer)


func _stop_monitoring() -> void:
	_area.monitoring = false
	_area.monitorable = false


#region fades
func _fade_in() -> void:
	_fade(0, 1)


func _fade_out() -> void:
	_fade(1, 0)
	_fade_tween.tween_callback(queue_free)


func _fade(start_a: float, end_a: float) -> void:
	if _fade_tween:
		_fade_tween.kill()
	modulate.a = start_a
	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_property(self, "modulate:a", end_a, 0.25)
#endregion


#region node updates
func _update_expiration_timer(new_time: float) -> void:
	if not is_instance_valid(_expiration_timer):
		return
	_expiration_timer.stop()
	_expiration_timer.wait_time = new_time
	_expiration_timer.start()


func _update_shape_radius(new_radius: float) -> void:
	if _col_shape:
		_col_shape.shape.radius = new_radius
		queue_redraw()


func _update_colors() -> void:
	var parent = get_parent()
	if parent:
		if parent is Character:
			draw_color = Color(parent.draw_color, 0.25)
			outline_color = Color(parent.draw_color, 0.5)
#endregion


#region setters
func _set_radius(value: float) -> void:
	if value < 0:
		value = 0
	radius = value
	radius_changed.emit(radius)


func _set_expiration_time(time: float) -> void:
	if time < 0:
		return
	expiration_time = time
	expiration_time_changed.emit(time)


func _set_durability(value: int) -> void:
	if value < 0:
		value = 0
	durability = value
	durability_changed.emit(value)
#endregion
