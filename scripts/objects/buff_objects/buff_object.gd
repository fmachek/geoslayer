class_name BuffObject
extends Node2D

@export var draw_color: Color = Color.GRAY # Fill draw color
@export var outline_color: Color = Color.DIM_GRAY # Outline draw color

@export var buff_amount: int
@export var buff_duration: int
@export var target_stat_name: String

var was_picked_up: bool = false

var size_tween: Tween
var rot_speed = 3

func _process(delta: float) -> void:
	global_rotation += rot_speed*delta

func _draw():
	var width = $Area2D/CollisionShape2D.shape.size.x
	var height = $Area2D/CollisionShape2D.shape.size.y
	draw_rect(Rect2(-width/2, -height/2, width, height), draw_color)
	draw_rect(Rect2(-width/2, -height/2, width, height), outline_color, false, 4)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if was_picked_up:
		return
	if body is PlayerCharacter:
		var stat: CharacterStat = body.get(target_stat_name)
		if stat:
			was_picked_up = true
			buff_stat(stat)

func buff_stat(stat: CharacterStat) -> void:
	var buff := Buff.new(buff_amount, buff_duration)
	buff.apply_to_stat(stat)
	spawn_pickup_label(buff)
	size_tween = create_tween()
	size_tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
	size_tween.parallel().tween_property(self, "modulate:a", 0, 0.25)
	size_tween.tween_callback(queue_free)

func spawn_pickup_label(buff: Buff) -> void:
	var buff_pickup_label = load("res://scenes/user_interface/world_labels/buff_pickup_label.tscn").instantiate()
	get_parent().add_child(buff_pickup_label)
	buff_pickup_label.global_position = self.global_position
	buff_pickup_label.load_buff(buff)
	buff_pickup_label.play_tween()
