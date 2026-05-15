class_name ParticleDoT
extends DamageOverTime

var particle_scene := preload(
		"res://scenes/particle_effects/dot/poison_particles.tscn")

var particle_color: Color = Color.WHITE
var particles: FreeParticles


func _init(damage: int, tick_time_sec: float, total_ticks: int) -> void:
	super(damage, tick_time_sec, total_ticks)
	var defer = func(target): call_deferred("_spawn_particles", target)
	applied_to_target.connect(defer)
	tree_exiting.connect(_stop_particles)


func _spawn_particles(target: Character) -> void:
	particles = particle_scene.instantiate()
	particles.color = particle_color
	target.add_child(particles)
	particles.global_position = target.global_position
	var target_shape = target.get_node("CollisionShape2D").shape
	if target_shape is CircleShape2D:
		var radius: float = target_shape.radius
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
		particles.emission_sphere_radius = radius
	elif target_shape is RectangleShape2D:
		particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		particles.emission_rect_extents = target_shape.size / 2


func _stop_particles() -> void:
	if not is_instance_valid(particles):
		return
	particles.emitting = false
