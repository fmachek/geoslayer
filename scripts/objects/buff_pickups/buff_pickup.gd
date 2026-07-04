class_name BuffPickup
extends Node2D

signal picked_up()

const _LABEL_SCENE := preload(
	"res://scenes/user_interface/world_labels/buff_pickup_object_label.tscn"
)
const OPTION_AMOUNT: int = 3
const STAT_SCALE: float = 1.1

@export var draw_color: Color = Color.GRAY
@export var outline_color: Color = Color.DIM_GRAY
@export var rot_speed: float = 3.0
@export var stat_multiplier: float = 1.0

var possible_stats: Dictionary[String, int] = {
	"Health": 2,
	"Damage": 2,
	"Speed": 1
}
var buff_options: Dictionary[Buff, String] = {}

var _was_picked_up := false
var _scale_tween: Tween

@onready var _area: Area2D = get_node("Area2D")
@onready var _col_shape: CollisionShape2D = _area.get_node("CollisionShape2D")


func _ready() -> void:
	picked_up.connect(SignalBus.picked_up_buff.emit.bind(buff_options))
	picked_up.connect(_play_scale_tween)
	_update_stat_multiplier()
	_spawn_label()
	_generate_buff_options()


func _process(delta: float) -> void:
	global_rotation += rot_speed * delta


func _draw() -> void:
	var shape = _col_shape.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var rect := Rect2(-width / 2, -height / 2, width, height)
	var outline_width: float = 4.0
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, outline_width)


func _generate_buff_options() -> void:
	buff_options.clear()
	for i in range(OPTION_AMOUNT):
		var stat_name: String = possible_stats.keys().pick_random()
		if not stat_name:
			return
		var multiplier: int = possible_stats.get(stat_name, 1)
		
		possible_stats.erase(stat_name)
		
		var buff_amount: int = randi_range(10, 20)
		buff_amount *= multiplier
		buff_amount = float(buff_amount) * stat_multiplier
		
		var buff_duration: int = randi_range(20, 40)
		
		var buff := Buff.new(buff_amount, buff_duration)
		buff_options[buff] = stat_name


func _update_stat_multiplier() -> void:
	var world: World = WorldManager.current_world
	if not is_instance_valid(world):
		return
	var wave_manager: WaveManager = world.wave_manager
	if not is_instance_valid(wave_manager):
		return
	var current_wave: int = wave_manager.current_wave
	if not current_wave:
		current_wave = 1
	stat_multiplier = pow(STAT_SCALE, current_wave - 1) * world.stat_multiplier


func _on_area_2d_body_entered(body: Node2D) -> void:
	call_deferred("_handle_pick_up", body)


func _handle_pick_up(body: Node2D) -> void:
	if body is not PlayerCharacter or _was_picked_up:
		return
	_was_picked_up = true
	picked_up.emit()


func _play_scale_tween() -> void:
	_scale_tween = create_tween()
	var tween_duration: float = 0.25
	_scale_tween.tween_property(self, "scale", Vector2.ZERO, tween_duration)
	_scale_tween.parallel().tween_property(self, "modulate:a", 0, tween_duration)
	_scale_tween.tween_callback(queue_free)


func _spawn_label() -> void:
	var label: PickupLabel = _LABEL_SCENE.instantiate()
	label.global_position = global_position - Vector2(label.size.x / 2, 60)
	picked_up.connect(label.fade_out)
	var parent = get_parent()
	if is_instance_valid(parent):
		parent.call_deferred("add_child", label)
