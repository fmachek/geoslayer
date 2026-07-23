class_name NecromancerConnection
extends Node2D

var necromancer: Necromancer
var target: Enemy

@onready var line: Line2D = $Line2D
@onready var target_particles: CPUParticles2D = $TargetParticles


func _ready() -> void:
	if not is_instance_valid(necromancer) or not is_instance_valid(target):
		return
	line.modulate = necromancer.draw_color
	target_particles.modulate = necromancer.draw_color
	target_particles.position = to_local(target.global_position)
	target_particles.show()


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(necromancer) or not is_instance_valid(target):
		return
	var points: Array[Vector2] = [
		to_local(necromancer.global_position),
		to_local(target.global_position)
	]
	line.points = points
	target_particles.position = to_local(target.global_position)


func load_characters(necromancer: Necromancer, target: Enemy) -> void:
	self.necromancer = necromancer
	self.target = target
