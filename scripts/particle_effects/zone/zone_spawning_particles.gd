class_name ZoneSpawningParticles
extends Node2D
## Represents a node which plays [Zone] spawning visual effects.
##
## Contains two [CPUParticles2D] nodes: [member casting_particles]
## and [member cast_finish_particles]. The first is used
## when the [Zone] is being spawned by an [Ability]. The second is used when
## the [Ability] cast finishes. After these two effects are played, the
## node is freed.

## Color of the particle effects.
var particle_color: Color = Color(1.0, 1.0, 1.0, 1.0)
## Radius of the [Zone] being spawned.
var radius: int = 200: set = _set_radius
var _were_interrupted: bool = false
## Particles displayed while the [Zone] is being spawned.
@onready var casting_particles: CPUParticles2D = $ZoneCastingParticles
## Particles displayed when [Zone] appears.
@onready var cast_finish_particles: CPUParticles2D = $ZoneCastFinishParticles


func _ready() -> void:
	casting_particles.color = particle_color
	cast_finish_particles.color = particle_color
	_update_particle_radius()


## Updates [member particle_color] to match
## the [param ability] caster's draw color. Also connects to
## [signal Ability.finished_casting] and [signal Ability.character.tree_exiting].
## That ensures that the cast finish particles can be shown and that the casting
## particles disappear if the caster exits the tree while casting. Also connects
## [signal Ability.was_interrupted] so that the particles disappear when
## the ability is interrupted.
func connect_to_ability(ability: Ability) -> void:
	particle_color = ability.character.draw_color
	ability.finished_casting.connect(_on_ability_finished_casting)
	ability.character.tree_exiting.connect(_on_interrupt)
	ability.was_interrupted.connect(_on_interrupt)


# Stop casting particles and show finish particles.
# After the finish particles are done, queue free.
func _on_ability_finished_casting() -> void:
	if not _were_interrupted:
		casting_particles.emitting = false
		cast_finish_particles.emitting = true
		cast_finish_particles.finished.connect(queue_free)


func _on_interrupt() -> void:
	_were_interrupted = true
	casting_particles.emitting = false
	casting_particles.finished.connect(queue_free)


# Updates radius of the casting particles emission shape.
func _update_particle_radius() -> void:
	if casting_particles:
		casting_particles.emission_ring_inner_radius = radius / 2
		casting_particles.emission_ring_radius = radius


func _set_radius(value: int) -> void:
	if value <= 0:
		return
	radius = value
	_update_particle_radius()
