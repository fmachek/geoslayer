class_name Dodge
extends Ability

const DASH_PARTICLE_SCENE := preload(
	"res://scenes/particle_effects/dash_particles.tscn"
)

var dash_distance: float = 150.0
var dash_duration: float = 0.125


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_cast_time: float = dash_duration
	var ability_description: String = "Perform a short dash."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	pass


func _handle_casting() -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	if direction == Vector2.ZERO:
		direction = Vector2(1, 0)
	var dash: Dash = character.dash(dash_distance, dash_duration, direction)
	
	var dash_particles: FreeParticles = DASH_PARTICLE_SCENE.instantiate()
	character.add_child(dash_particles)
	dash_particles.global_position = character.global_position
	dash_particles.color = character.draw_color
	dash_particles.direction = -direction
	dash_particles.lifetime = dash_duration
	dash_particles.emitting = true
	
	dash.ended.connect(
		func():
			if is_instance_valid(dash_particles):
				dash_particles.emitting = false
	)
	dash.ended.connect(finished_casting.emit)
