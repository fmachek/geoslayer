class_name Mine
extends Node2D

signal exploded()
signal became_active()
signal became_inactive()
signal draw_color_changed(new_color: Color)
signal outline_color_changed(new_color: Color)
signal body_radius_changed(new_value: float)
signal detection_area_radius_changed(new_value: float)

const DAMAGE_AREA_SCENE := preload(
		"res://scenes/objects/attacks/instant_damage_area.tscn")
const EXPLOSION_PARTICLE_SCENE := preload(
		"res://scenes/particle_effects/mines/mine_explosion_particles.tscn")
const SMOKE_PARTICLE_SCENE := preload(
		"res://scenes/particle_effects/mines/mine_smoke_particles.tscn")

var draw_color: Color = Color.WHITE: set = set_draw_color
var outline_color: Color = draw_color.darkened(0.3)
var body_radius: float = 24.0: set = set_body_radius
var detection_area_radius: float = 48.0: set = set_detection_area_radius
var explosion_radius: float = 200.0

var is_active: bool = true: set = set_is_active
var spawner: Character: set = set_spawner
var explosion_damage: int = 50
var explosion_knockback: float = 1000.0
var automatic_explosion_time: float = 3.0
var stun_duration: float = 0.75

var _can_detect_projectiles: bool = true
var _alpha_tween: Tween
var _progress_bar_tween: Tween

@onready var _body_area: Area2D = get_node("BodyArea")
@onready var _body_area_shape: CollisionShape2D = _body_area.get_node("CollisionShape2D")
@onready var _char_det_area: Area2D = get_node("CharacterDetectionArea")
@onready var _char_det_area_shape: CollisionShape2D = _char_det_area.get_node("CollisionShape2D")
@onready var _explosion_timer: Timer = get_node("ExplosionTimer")
@onready var _progress_bar: ProgressBar = get_node("ExplosionProgressBar")


func _ready() -> void:
	draw_color_changed.connect(queue_redraw)
	draw_color_changed.connect(_update_progress_bar_color)
	outline_color_changed.connect(queue_redraw)
	body_radius_changed.connect(_update_body_shape)
	detection_area_radius_changed.connect(_update_detection_area_shape)
	became_inactive.connect(_progress_bar.hide)
	
	_update_body_shape(body_radius)
	_update_detection_area_shape(detection_area_radius)
	_update_detection_collision_mask(spawner)
	_update_progress_bar_color(draw_color)
	
	_explosion_timer.wait_time = automatic_explosion_time
	_explosion_timer.start()
	
	_fade_in()
	_tween_progress_bar()


func _draw() -> void:
	_draw_body()
	_draw_button()


func explode() -> void:
	if not is_active:
		return
	is_active = false
	exploded.emit()
	if _alpha_tween:
		_alpha_tween.kill()
	self_modulate.a = 0.0
	_spawn_smoke_particles()
	_spawn_explosion_particles()
	var area: InstantDamageArea = _spawn_damage_area()
	_connect_area_signals(area)


func disappear() -> void:
	is_active = false
	_fade_out()
	var tree = get_tree()
	if is_instance_valid(tree):
		await tree.create_timer(1.0).timeout
		queue_free()


#region setters
func set_draw_color(color: Color) -> void:
	draw_color = color
	draw_color_changed.emit(color)


func set_outline_color(color: Color) -> void:
	outline_color = color
	outline_color_changed.emit(color)


func set_body_radius(value: float) -> void:
	if value < 0:
		value = 0
	body_radius = value
	body_radius_changed.emit(value)


func set_detection_area_radius(value: float) -> void:
	if value < 0:
		value = 0
	detection_area_radius = value
	detection_area_radius_changed.emit(value)


func set_is_active(value: bool) -> void:
	is_active = value
	if value:
		became_active.emit()
	else:
		became_inactive.emit()


func set_spawner(new_spawner: Character) -> void:
	if is_instance_valid(spawner):
		spawner.tree_exiting.disconnect(disappear)
	spawner = new_spawner
	new_spawner.tree_exiting.connect(disappear)
#endregion setters


func _spawn_damage_area() -> InstantDamageArea:
	var area: InstantDamageArea = DAMAGE_AREA_SCENE.instantiate()
	area.damage = explosion_damage
	area.radius = explosion_radius
	area.source = spawner
	area.global_position = global_position
	area.draw_color = Color(draw_color, 0.1).darkened(0.3)
	area.outline_color = Color(draw_color, 0.3).darkened(0.3)
	get_parent().add_child(area)
	return area


func _connect_area_signals(area: InstantDamageArea) -> void:
	area.handled_body.connect(_apply_knockback)
	area.handled_body.connect(_apply_stun)
	area.tree_exiting.connect(queue_free)


func _apply_knockback(body: Node2D) -> void:
	if body is Character:
		var direction_to_body: Vector2 = global_position.direction_to(body.global_position)
		var normalized: Vector2 = direction_to_body.normalized()
		body.apply_knockback(explosion_knockback * normalized)


func _apply_stun(body: Node2D) -> void:
	if body is Character:
		body.stun(stun_duration)


func _update_detection_collision_mask(char: Character) -> void:
	CollisionMaskFunctions.set_area_collision_mask(_char_det_area, char)


func _on_character_detection_area_body_entered(body: Node2D) -> void:
	if body is Character:
		call_deferred("explode")


func _on_body_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	if not _can_detect_projectiles:
		return
	var parent = area.get_parent()
	if not is_instance_valid(parent):
		return
	if parent is Projectile:
		var projectile: Projectile = parent
		if not projectile.can_explode:
			return
		if projectile.projectile_properties.source == spawner:
			_can_detect_projectiles = false
			if not projectile is PiercingProjectile:
				# Piercing projectiles pierce through mines
				projectile.call_deferred("explode")
			call_deferred("explode")
	elif parent is Boomerang:
		var boomerang: Boomerang = parent
		if boomerang.is_inactive:
			return
		if boomerang.caster == spawner:
			_can_detect_projectiles = false
			call_deferred("explode")


#region shape updates
func _update_body_shape(new_radius: float) -> void:
	if not is_instance_valid(_body_area_shape):
		return
	var shape: CircleShape2D = _body_area_shape.shape
	shape.radius = new_radius
	queue_redraw()


func _update_detection_area_shape(new_radius: float) -> void:
	if not is_instance_valid(_char_det_area):
		return
	var shape: CircleShape2D = _char_det_area_shape.shape
	shape.radius = new_radius
	queue_redraw()
#endregion


#region draw methods
func _draw_body() -> void:
	# Draw fill
	var circle_pos := Vector2.ZERO
	draw_circle(circle_pos, body_radius, draw_color)
	
	# Draw outline
	var outline_width: float = body_radius / 8
	var outline_radius: float = body_radius - outline_width / 2
	var start_angle: float = 0.0
	var end_angle: float = TAU
	var point_count: int = 64
	var antialiased: bool = true
	draw_arc(Vector2.ZERO, outline_radius, start_angle,
			end_angle, point_count, outline_color, outline_width,
			antialiased)


func _draw_button() -> void:
	var outline_radius: float = body_radius / 2
	var outline_width: float = body_radius / 8
	var start_angle: float = 0.0
	var end_angle: float = TAU
	var point_count: int = 32
	var antialiased: bool = true
	draw_arc(Vector2.ZERO, outline_radius, start_angle,
			end_angle, point_count, outline_color, outline_width,
			antialiased)
#endregion


#region visuals
func _spawn_explosion_particles() -> void:
	_spawn_particles(EXPLOSION_PARTICLE_SCENE, draw_color)


func _spawn_smoke_particles() -> void:
	_spawn_particles(SMOKE_PARTICLE_SCENE, Color(draw_color.darkened(0.5), 0.5))


func _spawn_particles(scene: PackedScene, particle_color: Color) -> void:
	var particles: FreeParticles = scene.instantiate()
	particles.color = particle_color
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true


func _fade_in() -> void:
	_fade(0.0, 1.0)


func _fade_out() -> void:
	_fade(1.0, 0.0)


func _fade(start_alpha: float, end_alpha: float) -> void:
	if _alpha_tween:
		_alpha_tween.kill()
	self_modulate.a = start_alpha
	_alpha_tween = create_tween()
	var fade_time: float = 0.25
	_alpha_tween.tween_property(self, "self_modulate:a", end_alpha, fade_time)


func _tween_progress_bar() -> void:
	if _progress_bar_tween:
		_progress_bar_tween.kill()
	_progress_bar.value = 0.0
	_progress_bar_tween = create_tween()
	var max_value: float = _progress_bar.max_value
	_progress_bar_tween.tween_property(_progress_bar, "value", max_value, automatic_explosion_time)
	_progress_bar_tween.tween_callback(_progress_bar.hide)


func _update_progress_bar_color(new_color: Color) -> void:
	var stylebox: StyleBoxFlat = _progress_bar.get_theme_stylebox("fill")
	stylebox.bg_color = new_color
#endregion
