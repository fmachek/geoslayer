extends Node2D

@export var character_scene: PackedScene = preload("res://scenes/characters/character.tscn")

@export var draw_color := Color(0.447, 0.447, 0.447, 1.0)
@export var outline_color := Color(0.352, 0.352, 0.352, 1.0)

func _draw():
	var radius = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)

func spawn_character() -> void:
	var character: Character = character_scene.instantiate()
	character.global_position = global_position
	get_parent().add_child(character)

func _on_wave_started() -> void:
	spawn_character()
