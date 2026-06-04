class_name Boomerang
extends Node2D

signal draw_color_changed(new_draw_color: Color)
signal outline_color_changed(new_outline_color: Color)
signal polygon_changed(new_polygon: PackedVector2Array)
signal caster_changed(new_caster: Character)
signal returned_to_caster()
signal became_inactive()

var draw_color: Color = Color.WHITE: set = set_draw_color
var outline_color: Color = Color.GRAY: set = set_outline_color

var caster: Character: set = set_caster
var base_damage: int = 40
var damage_multiplier: float = 1.0
var travel_speed: float = 500.0
var travel_direction: Vector2 = Vector2.ONE
var rotation_speed: float = 20.0
var return_speed_increase: float = 50.0
var knockback: float = 400.0

var return_time: float = 1.0
var is_returning: bool = false
var is_inactive: bool = false: set = set_is_inactive

var _characters_hit: Array[Character] = []
var _fade_tween: Tween
var _scale_tween: Tween
var _tween_duration: float = 0.25

@onready var _body_area: Area2D = get_node("BodyArea")
@onready var _caster_detection_area: Area2D = get_node("CasterDetectionArea")
@onready var _polygon: CollisionPolygon2D = _body_area.get_node("CollisionPolygon2D")
@onready var _return_timer: Timer = get_node("ReturnTimer")


func _ready() -> void:
	draw_color_changed.connect(queue_redraw.unbind(1))
	outline_color_changed.connect(queue_redraw.unbind(1))
	became_inactive.connect(queue_redraw)
	
	_body_area.body_entered.connect(_on_body_entered)
	
	_return_timer.wait_time = return_time
	_return_timer.one_shot = true
	_return_timer.timeout.connect(return_to_caster)
	
	returned_to_caster.connect(disappear)
	
	if is_instance_valid(caster):
		_update_collision_mask(caster)
		_match_colors_with_caster(caster)
		_update_damage_multiplier(caster)
	
	_return_timer.start()


func _physics_process(delta: float) -> void:
	if is_returning:
		if is_instance_valid(caster):
			# Update direction so that the boomerang travels back to the caster
			var new_direction := (caster.global_position - global_position).normalized()
			travel_direction = new_direction
			# Speed up to catch up with caster
			travel_speed += return_speed_increase * delta
	if not is_inactive:
		global_position += travel_direction * travel_speed * delta
		global_rotation += rotation_speed * delta


func _draw() -> void:
	if not is_inactive:
		_draw_trace()
	
	var outline_width: float = 4.0
	draw_colored_polygon(_polygon.polygon, draw_color)
	var polyline := _polygon.polygon
	polyline.append(_polygon.polygon.get(0))
	draw_polyline(polyline, outline_color, outline_width)


func _draw_trace() -> void:
	var radius: float = abs(_polygon.polygon.get(0).x)
	var color := Color(draw_color, 0.2)
	draw_circle(Vector2.ZERO, radius, color)


func return_to_caster() -> void:
	if is_returning:
		return
	_return_timer.stop()
	if not is_instance_valid(caster):
		# Don't return to caster, disappear instead
		disappear()
		return
	is_returning = true
	_characters_hit.clear()
	# Start monitoring for caster
	_caster_detection_area.monitoring = true
	_caster_detection_area.body_entered.connect(_check_caster_detection)
	_check_for_collisions() # Checks for collisions immediately
	caster.tree_exiting.connect(disappear)


func disappear() -> void:
	if is_inactive: # Already is disappearing
		return
	is_inactive = true
	call_deferred("_stop_area_monitors")
	if is_instance_valid(caster):
		if caster.tree_exiting.is_connected(disappear):
			caster.tree_exiting.disconnect(disappear)
	_fade_out()
	_shrink()


func update_polygon(polygon: PackedVector2Array) -> void:
	_polygon.polygon = polygon
	polygon_changed.emit(polygon)


func set_draw_color(new_draw_color: Color) -> void:
	var old_draw_color: Color = draw_color
	draw_color = new_draw_color
	if old_draw_color != new_draw_color:
		draw_color_changed.emit(new_draw_color)


func set_outline_color(new_outline_color: Color) -> void:
	var old_outline_color: Color = outline_color
	outline_color = new_outline_color
	if old_outline_color != new_outline_color:
		outline_color_changed.emit(new_outline_color)


func set_caster(new_caster: Character) -> void:
	caster = new_caster
	caster_changed.emit(new_caster)


func set_is_inactive(new_value: bool) -> void:
	is_inactive = new_value
	if new_value:
		became_inactive.emit()


func _deal_damage(character: Character) -> void:
	if character in _characters_hit:
		return
	character.take_damage(base_damage * damage_multiplier)


func _apply_knockback(character: Character) -> void:
	if character in _characters_hit:
		return
	character.apply_knockback(knockback * travel_direction)


func _stop_area_monitors() -> void:
	_body_area.monitoring = false
	_body_area.monitorable = false
	_caster_detection_area.monitoring = false


func _update_collision_mask(caster_character: Character) -> void:
	if not is_instance_valid(_body_area):
		return
	_body_area.collision_mask = 1
	CollisionMaskFunctions.set_area_collision_mask(_body_area, caster_character)


func _match_colors_with_caster(caster_character: Character) -> void:
	draw_color = caster_character.draw_color
	outline_color = caster_character.outline_color


func _update_damage_multiplier(caster_character: Character) -> void:
	var caster_damage: int = caster_character.damage.max_value_after_buffs
	damage_multiplier = float(caster_damage) / 100


func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		_deal_damage(body)
		_apply_knockback(body)
		_characters_hit.append(body)
	elif body is TileMapLayer:
		return_to_caster()


func _check_caster_detection(body: Node2D) -> void:
	if body == caster:
		returned_to_caster.emit()


func _check_for_collisions() -> void:
	var overlapping_bodies: Array[Node2D] = _body_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body is Character:
			_deal_damage(body)


func _fade_out() -> void:
	if _fade_tween:
		_fade_tween.kill()
	modulate.a = 1
	_fade_tween = create_tween()
	var final_alpha: float = 0.0
	_fade_tween.tween_property(self, "modulate:a", final_alpha, _tween_duration)
	_fade_tween.tween_callback(queue_free)


func _shrink() -> void:
	if _scale_tween:
		_scale_tween.kill()
	scale = Vector2.ONE
	_scale_tween = create_tween()
	var final_scale := Vector2.ZERO
	_scale_tween.tween_property(self, "scale", final_scale, _tween_duration)
