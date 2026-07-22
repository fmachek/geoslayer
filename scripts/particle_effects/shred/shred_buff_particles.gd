class_name ShredBuffParticles
extends Node2D

var shield_particle_color: Color = Color.WHITE
var speed_particle_color: Color = Color.WHITE

@onready var _shield_particles: CPUParticles2D = get_node("ShieldParticles")
@onready var _speed_particles: CPUParticles2D = get_node("SpeedParticles")


func _ready() -> void:
	_shield_particles.finished.connect(queue_free)
	_shield_particles.color = shield_particle_color
	_speed_particles.color = speed_particle_color
	_shield_particles.emitting = true
	_speed_particles.emitting = true
