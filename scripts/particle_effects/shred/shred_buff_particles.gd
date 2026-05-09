class_name ShredBuffParticles
extends Node2D

@onready var _shield_particles: CPUParticles2D = get_node("ShieldParticles")
@onready var _speed_particles: CPUParticles2D = get_node("SpeedParticles")


func _ready() -> void:
	_shield_particles.finished.connect(queue_free)
	_shield_particles.emitting = true
	_speed_particles.emitting = true
