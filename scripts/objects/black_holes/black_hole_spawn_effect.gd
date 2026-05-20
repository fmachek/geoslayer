class_name BlackHoleSpawnEffect
extends Node2D

const _PARTICLE_SCENE := preload(
	"res://scenes/objects/black_holes/black_hole_spawn_particle.tscn"
)

var draw_color: Color = Color.BLACK
var outline_color: Color = Color.GRAY

var outer_radius: float = 300.0
var clump_radius: float = 0.0: set = _set_clump_radius
var cast_time: float = 2.0
var collapse_time: float = 0.2
var particle_amount: int = 10

var was_stopped: bool = false
var _clump_radius_tween: Tween
var _fade_tween: Tween

@onready var _explosion_particles: CPUParticles2D = get_node("ExplosionParticles")


func _ready() -> void:
	_explosion_particles.finished.connect(queue_free)
	_explosion_particles.color = draw_color
	play()


func _draw() -> void:
	draw_circle(Vector2.ZERO, clump_radius, draw_color)
	var outline_width: float = clump_radius / 8
	draw_arc(Vector2.ZERO, clump_radius, 0.0, TAU, 64, outline_color, outline_width)


func play() -> void:
	var time_available: float = cast_time - collapse_time
	var movement_duration: float = time_available / particle_amount

	for i in range(particle_amount):
		if was_stopped: # Stop spawning particles if stopped
			return
		var particle: BlackHoleSpawnParticle = spawn_particle(movement_duration)
		if i == particle_amount - 1:
			particle.reached_center.connect(_play_collapse)
		else:
			var radius_increase: float = particle.radius / 2
			var radius_tween_duration: float = movement_duration / 2
			particle.reached_center.connect(
				_increase_clump_radius.bind(radius_increase, radius_tween_duration)
			)
			await particle.reached_center


func bind_to_casting_ability(ability: Ability) -> void:
	ability.tree_exiting.connect(stop)
	ability.was_interrupted.connect(stop)


func stop() -> void:
	if was_stopped:
		return
	was_stopped = true
	_fade_out()


func spawn_particle(movement_duration: float) -> BlackHoleSpawnParticle:
	var random_angle: float = randf_range(0.0, TAU)
	var direction := Vector2.ONE.normalized().rotated(random_angle)
	var particle_pos: Vector2 = direction * outer_radius
	
	var particle: BlackHoleSpawnParticle = _PARTICLE_SCENE.instantiate()
	particle.draw_color = draw_color
	particle.movement_duration = movement_duration
	add_child(particle)
	particle.move_to_center(particle_pos, Vector2.ZERO)
	return particle


func _increase_clump_radius(amount: float, tween_time: float) -> void:
	if was_stopped: # Don't increase if the effect was stopped
		return
	if _clump_radius_tween:
		_clump_radius_tween.kill()
	_clump_radius_tween = create_tween()
	var current_value: float = clump_radius
	var end_value: float = current_value + amount
	_clump_radius_tween.tween_method(
		_set_clump_radius, current_value, end_value, tween_time
	)


func _set_clump_radius(new_radius: float) -> void:
	clump_radius = new_radius
	queue_redraw()


func _play_collapse() -> void:
	if _clump_radius_tween:
		_clump_radius_tween.kill()
	_clump_radius_tween = create_tween()
	var start_radius: float = clump_radius
	var end_radius: float = 0.0
	_clump_radius_tween.tween_method(
		_set_clump_radius, start_radius, end_radius, collapse_time
	)
	_clump_radius_tween.tween_callback(func(): _explosion_particles.emitting = true)


func _fade_out() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	var end_alpha: float = 0.0
	var fade_duration: float = 1.0
	_fade_tween.tween_property(self, "modulate:a", end_alpha, fade_duration)
	_fade_tween.tween_callback(queue_free)
