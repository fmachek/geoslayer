class_name ShieldApplicationArea
extends InstantArea
## Represents a round area which applies a [Shield] to all [Character]s
## who are the [member source]'s ally (if the [member source] is a [Character]).

const _SHIELD_SCENE := preload("res://scenes/objects/shields/shield.tscn")

## Time until the [Shield]s disappear, in seconds.
var shield_duration: float = 2.0
## Radius of the [Shield]s.
var shield_radius: float = 82.0
## Durability of the [Shield]s.
var shield_durability: int = 10

@onready var _shield_particles: CPUParticles2D = $ShieldParticles


func _ready() -> void:
	super()
	_update_color()
	_update_particles()
	_move_particles()


func _perform(body: Node2D) -> void:
	if body is Character and body != source:
		var shield: Shield = _SHIELD_SCENE.instantiate()
		shield.expiration_time = shield_duration
		shield.radius = shield_radius
		shield.durability = shield_durability
		body.add_child(shield)


func _update_area_mask(source: Node2D) -> void:
	CollisionMaskFunctions.set_friendly_area_collision_mask(_area, source)


func _move_particles() -> void:
	_shield_particles.reparent(get_parent())


func _update_color() -> void:
	if source is Character:
		draw_color = Color(source.draw_color, 0.3)
		outline_color = Color(source.outline_color, 0.3)


func _update_particles() -> void:
	_shield_particles.emission_sphere_radius = radius
	_shield_particles.color = Color(draw_color, 0.5)
	_shield_particles.emitting = true
