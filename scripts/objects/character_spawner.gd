extends Node2D

@export var character_scene: PackedScene = preload("res://scenes/characters/character.tscn")

@export var draw_color := Color(0.447, 0.447, 0.447, 1.0)
@export var outline_color := Color(0.352, 0.352, 0.352, 1.0)

# Used for spawning in waves.
# Allows for placement in a scene and setting the waves during which
# the character should be spawned via the inspector.
@export var spawn_waves: PackedInt32Array # Used for spawning in waves

func _draw():
	var radius = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)

func spawn_character() -> void:
	var character: Character = character_scene.instantiate()
	character.global_position = global_position
	get_parent().add_child(character)

# Checks if the new wave is in the spawn_waves array.
# If it is, then a character shold be spawned.
func _on_wave_changed(wave: int) -> void:
	if wave in spawn_waves:
		spawn_character()
