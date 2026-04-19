class_name BuffObject
extends Node2D
## Represents an object which buffs a [PlayerCharacter]'s [CharacterStat]
## on pickup.

# Used to instantiate BuffPickupLabel.
const _PICKUP_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/buff_pickup_label.tscn")

## Fill color of the shape.
@export var draw_color: Color = Color.GRAY
## Outline color of the shape.
@export var outline_color: Color = Color.DIM_GRAY
## Amount by which the [CharacterStat] will be modified on pickup.
@export var buff_amount: int
## Duration for which the [CharacterStat] will be modified after pickup.
@export var buff_duration: int
## Name of the [CharacterStat] which is to be modified.
@export var target_stat_name: String
## Speed at which the [BuffObject] rotates every frame.
@export var rot_speed: float = 3.0

# True if the BuffObject has been picked up.
var _was_picked_up := false
# Used to tween scale on pickup.
var _scale_tween: Tween


func _process(delta: float) -> void:
	global_rotation += rot_speed * delta


func _draw() -> void:
	var col_shape: CollisionShape2D = $Area2D/CollisionShape2D
	var shape = col_shape.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var rect := Rect2(-width / 2, -height / 2, width, height)
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, 4)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _was_picked_up:
		return
	if body is PlayerCharacter:
		var stat: CharacterStat = body.get(target_stat_name)
		if stat:
			_was_picked_up = true
			_buff_stat(stat)


func _buff_stat(stat: CharacterStat) -> void:
	var buff := Buff.new(buff_amount, buff_duration)
	buff.apply_to_stat(stat)
	_spawn_pickup_label(buff)
	_play_scale_tween()


func _play_scale_tween() -> void:
	_scale_tween = create_tween()
	_scale_tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
	_scale_tween.parallel().tween_property(self, "modulate:a", 0, 0.25)
	_scale_tween.tween_callback(queue_free)


func _spawn_pickup_label(buff: Buff) -> void:
	var buff_pickup_label: BuffPickupLabel = _PICKUP_LABEL_SCENE.instantiate()
	get_parent().add_child(buff_pickup_label)
	buff_pickup_label.global_position = global_position
	buff_pickup_label.load_buff(buff)
	buff_pickup_label.play_tween()
