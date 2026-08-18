class_name AttackTile
extends Area2D

signal warned_player()
signal attack_timed_out()

var tile_size: int = 64
var attack_time: float = 1.5
var damage: int = 50
var attacking: bool = false

var draw_color: Color = Color.RED
var alpha_tween: Tween

@onready var col_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var attack_timer: Timer = get_node("AttackTimer")


func _ready() -> void:
	update_shape()
	attack_timer.wait_time = attack_time
	modulate.a = 0.0
	attack_timed_out.connect(perform_attack)


func _draw() -> void:
	var rect := Rect2(2, 2, col_shape.shape.size.x - 4, col_shape.shape.size.y - 4)
	draw_rect(rect, draw_color)


func start_attack() -> void:
	if attacking:
		return
	attacking = true
	modulate.a = 0.2
	attack_timer.start()
	warned_player.emit()


func perform_attack() -> void:
	var bodies: Array[Node2D] = get_overlapping_bodies()
	for body: Node2D in bodies:
		if body is PlayerCharacter:
			body.take_damage(damage)
	attacking = false


func update_shape() -> void:
	var new_shape := RectangleShape2D.new()
	new_shape.size = Vector2(tile_size, tile_size)
	col_shape.shape = new_shape
	col_shape.position = Vector2(tile_size / 2, tile_size / 2)


func _on_attack_timer_timeout() -> void:
	if alpha_tween:
		alpha_tween.kill()
	modulate.a = 1.0
	alpha_tween = create_tween()
	alpha_tween.tween_property(self, "modulate:a", 0.0, 0.25)
	attack_timed_out.emit()
