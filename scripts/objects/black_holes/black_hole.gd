class_name BlackHole
extends Node2D

signal draw_color_changed(new_color: Color)
signal outline_color_changed(new_color: Color)
signal hole_radius_changed(new_radius: float)
signal gravity_area_radius_changed(new_radius: float)
signal caster_changed(new_caster: Character)

const _EXPLOSION_PARTICLES_SCENE := preload(
	"res://scenes/particle_effects/black_hole_explosion_particles.tscn"
)
const _DISC_PARTICLES_SCENE := preload(
	"res://scenes/particle_effects/disc_particles.tscn"
)

var draw_color: Color = Color.BLACK: set = set_draw_color
var outline_color: Color = Color.ORANGE: set = set_outline_color

var hole_radius: float = 50.0: set = set_hole_radius
var gravity_area_radius: float = 400.0: set = set_gravity_area_radius

var caster: Character: set = set_caster

var base_damage: int = 50
var caster_damage: int = 100
var expiration_time: float = 4.0
var drag: float = 50.0
var knockback: float = 1500.0

var _hole_size_tween: Tween
var _bar_tween: Tween

@onready var _hole_area_2d: Area2D = get_node("HoleBodyArea")
@onready var _gravity_area_2d: Area2D = get_node("GravityArea")
@onready var _disc_particles: CPUParticles2D = get_node("DiscParticles")
@onready var _expiration_timer: Timer = get_node("ExpirationTimer")
@onready var _particle_add_timer: Timer = get_node("ParticleAddTimer")
@onready var _progress_bar: ProgressBar = get_node("ExplosionProgressBar")


func _ready() -> void:
	_connect_signals()
	_update_caster_colors(caster)
	_create_hole_area_2d_shape(hole_radius)
	_create_gravity_area_2d_shape(gravity_area_radius)
	_set_hole_area_collision_mask(caster)
	_set_gravity_area_collision_mask(caster)
	_expiration_timer.wait_time = expiration_time
	var _particle_add_wait_time: float = expiration_time / 5
	_particle_add_timer.wait_time = _particle_add_wait_time
	_particle_add_timer.start()
	_expiration_timer.start()
	_update_progress_bar_color(draw_color)
	_start_progress_bar()
	call_deferred("_tween_hole_size")


func _physics_process(delta: float) -> void:
	var gravity_area_bodies: Array[Node2D] = _gravity_area_2d.get_overlapping_bodies()
	for body in gravity_area_bodies:
		if body is Character:
			var distance: float = global_position.distance_to(body.global_position)
			if distance < hole_radius:
				continue
			_apply_drag(body, delta)


func _draw() -> void:
	_draw_hole()
	_draw_gravity_area()


func explode() -> void:
	var gravity_area_bodies: Array[Node2D] = _gravity_area_2d.get_overlapping_bodies()
	_gravity_area_2d.monitoring = false
	for body in gravity_area_bodies:
		if body is Character:
			_handle_character_in_explosion(body)
	_spawn_explosion_particles()
	queue_free()


func set_draw_color(new_draw_color: Color) -> void:
	draw_color = new_draw_color
	draw_color_changed.emit(new_draw_color)


func set_outline_color(new_outline_color: Color) -> void:
	outline_color = new_outline_color
	outline_color_changed.emit(new_outline_color)


func set_hole_radius(new_radius: float) -> void:
	if new_radius < 0:
		new_radius = 0
	hole_radius = new_radius
	hole_radius_changed.emit(new_radius)
	queue_redraw()


func set_gravity_area_radius(new_radius: float) -> void:
	if new_radius < 0:
		new_radius = 0
	gravity_area_radius = new_radius
	gravity_area_radius_changed.emit(new_radius)
	queue_redraw()


func set_caster(new_caster: Character) -> void:
	caster = new_caster
	caster_damage = caster.damage.max_value_after_buffs
	caster_changed.emit(new_caster)


func _handle_character_in_explosion(character: Character) -> void:
	var character_pos: Vector2 = character.global_position
	var direction: Vector2 = global_position.direction_to(character_pos)
	var distance: float = global_position.distance_to(character_pos)
	var knockback_vector := direction * knockback
	var multiplier: float = (100 / distance) * 2
	if multiplier > 1.5:
		multiplier = 1.5
	knockback_vector *= multiplier
	character.apply_knockback(knockback_vector)
	_deal_damage(character, multiplier)


func _deal_damage(character: Character, distance_multiplier: float) -> void:
	if distance_multiplier > 1:
		distance_multiplier = 1
	var caster_damage_multiplier: float = float(caster_damage) / 100
	var final_damage: int = base_damage * distance_multiplier * caster_damage_multiplier
	character.take_damage(final_damage)


func _apply_drag(character: Character, delta: float) -> void:
	var direction: Vector2 = global_position.direction_to(character.global_position)
	var velocity: Vector2 = -(direction * drag) * delta * 150
	character.add_velocity(velocity)


func _update_hole_area_2d_radius(new_radius: float) -> void:
	if not is_instance_valid(_hole_area_2d):
		return
	var col_shape: CollisionShape2D = _hole_area_2d.get_node("CollisionShape2D")
	var shape: CircleShape2D = col_shape.shape
	shape.radius = new_radius


func _update_gravity_area_2d_radius(new_radius: float) -> void:
	if not is_instance_valid(_gravity_area_2d):
		return
	var col_shape: CollisionShape2D = _gravity_area_2d.get_node("CollisionShape2D")
	var shape: CircleShape2D = col_shape.shape
	shape.radius = new_radius


func _update_caster_colors(new_caster: Character) -> void:
	outline_color = new_caster.draw_color
	if is_instance_valid(_disc_particles):
		_disc_particles.color = outline_color


func _create_hole_area_2d_shape(initial_radius: float) -> void:
	if not is_instance_valid(_hole_area_2d):
		return
	var new_shape := CircleShape2D.new()
	new_shape.radius = initial_radius
	var col_shape: CollisionShape2D = _hole_area_2d.get_node("CollisionShape2D")
	col_shape.shape = new_shape


func _create_gravity_area_2d_shape(initial_radius: float) -> void:
	if not is_instance_valid(_gravity_area_2d):
		return
	var new_shape := CircleShape2D.new()
	new_shape.radius = initial_radius
	var col_shape: CollisionShape2D = _gravity_area_2d.get_node("CollisionShape2D")
	col_shape.shape = new_shape


func _set_hole_area_collision_mask(hole_caster: Character) -> void:
	if not is_instance_valid(_hole_area_2d):
		return
	CollisionMaskFunctions.set_area_collision_mask(_hole_area_2d, hole_caster)


func _set_gravity_area_collision_mask(hole_caster: Character) -> void:
	if not is_instance_valid(_gravity_area_2d):
		return
	CollisionMaskFunctions.set_area_collision_mask(_gravity_area_2d, hole_caster)


func _connect_signals() -> void:
	draw_color_changed.connect(queue_redraw.unbind(1))
	outline_color_changed.connect(queue_redraw.unbind(1))
	hole_radius_changed.connect(_update_hole_area_2d_radius)
	gravity_area_radius_changed.connect(_update_gravity_area_2d_radius)
	caster_changed.connect(_update_caster_colors)
	caster_changed.connect(_set_hole_area_collision_mask)
	caster_changed.connect(_set_gravity_area_collision_mask)
	_expiration_timer.timeout.connect(explode)
	_particle_add_timer.timeout.connect(_add_disc_particles)


func _tween_hole_size() -> void:
	if _hole_size_tween:
		_hole_size_tween.kill()
	_hole_size_tween = create_tween()
	_hole_size_tween.set_trans(Tween.TRANS_SPRING)
	var start_radius: float = 0.0
	var end_radius: float = hole_radius
	var tween_duration: float = 0.5
	_hole_size_tween.tween_method(
		set_hole_radius, start_radius, end_radius, tween_duration
	)


func _spawn_explosion_particles() -> void:
	var particles: FreeParticles = _EXPLOSION_PARTICLES_SCENE.instantiate()
	particles.color = outline_color
	particles.global_position = global_position
	particles.emitting = true
	get_parent().add_child(particles)


func _add_disc_particles() -> void:
	var particles: CPUParticles2D = _DISC_PARTICLES_SCENE.instantiate()
	particles.color = outline_color
	add_child(particles)
	particles.global_position = global_position


func _draw_hole() -> void:
	var draw_position := Vector2.ZERO
	draw_circle(draw_position, hole_radius, draw_color)
	var start_angle: float = 0.0
	var end_angle: float = TAU
	var points: int = 32
	var outline_width: float = hole_radius / 8
	draw_arc(
		draw_position, hole_radius, start_angle, end_angle,
		points, outline_color, outline_width
	)


func _draw_gravity_area() -> void:
	var draw_position := Vector2.ZERO
	var start_angle: float = 0.0
	var end_angle: float = TAU
	var points: int = 128
	var arc_color := Color(outline_color, 0.5)
	var arc_width: float = 8.0
	draw_arc(
		draw_position, gravity_area_radius, start_angle, end_angle,
		points, arc_color, arc_width
	)


func _start_progress_bar() -> void:
	if _bar_tween:
		_bar_tween.kill()
	_bar_tween = _progress_bar.create_tween()
	_progress_bar.value = _progress_bar.min_value
	_bar_tween.tween_property(
		_progress_bar, "value", _progress_bar.max_value, expiration_time
	)
	_bar_tween.tween_callback(_progress_bar.hide)
	_progress_bar.show()


func _update_progress_bar_color(new_color: Color) -> void:
	var stylebox: StyleBoxFlat = _progress_bar.get_theme_stylebox("fill")
	stylebox.bg_color = new_color
