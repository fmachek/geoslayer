class_name BuffPickerUI
extends Control

signal selected_option(buff: Buff, stat_name: String, has_queue: bool)

const BUFF_CONTAINER_SCENE := preload(
	"res://scenes/user_interface/buff_picker/buff_container.tscn"
)

var showing: bool = false # True if "active"
# The queue is used if the player somehow picks up two buffs
# at once.
var _queue: Array[Dictionary] = []

@onready var option_container: HBoxContainer = %OptionContainer


func _ready() -> void:
	SignalBus.picked_up_buff.connect(_on_picked_up_buff)
	GameManager.paused_game.connect(_on_paused_game)
	GameManager.resumed_game.connect(_on_resumed_game)
	selected_option.connect(SignalBus.selected_buff.emit)


func load_options(options: Dictionary[Buff, String]) -> void:
	for buff: Buff in options.keys():
		var stat_name: String = options[buff]
		var buff_container: BuffContainer = BUFF_CONTAINER_SCENE.instantiate()
		buff_container.selected.connect(_handle_selection)
		buff_container.load_buff(buff, stat_name)
		option_container.add_child(buff_container)


func _handle_selection(buff: Buff, stat_name: String) -> void:
	showing = false
	for option in option_container.get_children():
		option.queue_free()
	var has_queue: bool = !_queue.is_empty()
	selected_option.emit(buff, stat_name, has_queue)
	if has_queue:
		var new_options: Dictionary[Buff, String] = _queue.pop_front()
		load_options(new_options)
	else:
		hide()


func _on_picked_up_buff(buff_options: Dictionary[Buff, String]) -> void:
	if showing:
		# Queue the new options because other options are 
		# already being shown
		_queue.append(buff_options)
		return
	showing = true
	load_options(buff_options)
	show()


func _on_paused_game() -> void:
	if showing:
		hide()


func _on_resumed_game() -> void:
	if showing:
		show()
