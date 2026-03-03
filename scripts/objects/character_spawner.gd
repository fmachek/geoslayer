extends Node2D

@export var character_scene: PackedScene = preload("res://scenes/characters/character.tscn")
@onready var timer: Timer = $Timer
@export var spawn_timer: int = 5

@export var draw_color := Color(0.447, 0.447, 0.447, 1.0)
@export var outline_color := Color(0.352, 0.352, 0.352, 1.0)

func _ready():
	$Timer.wait_time = spawn_timer

func _draw():
	var radius = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)

func _on_timer_timeout() -> void:
	var character: Character = character_scene.instantiate()
	character.global_position = global_position
	get_parent().add_child(character)
	character.died.connect(_on_character_died)
	timer.stop()

func _on_character_died():
	timer.start()
