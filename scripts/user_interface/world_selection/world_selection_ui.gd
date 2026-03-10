class_name WorldSelectionUI
extends Control

@onready var world_button_container = %WorldButtonContainer
var world_selection_button_scene: PackedScene = preload("res://scenes/user_interface/world_selection/world_selection_button.tscn")
var world_number_label_tween: Tween

var selected_world_number: int = -1

signal enter_world_pressed(selected_world_number: int)

func _ready() -> void:
	%EnterWorldButton.pressed.connect(_on_enter_world_button_pressed)
	%BackToMenuButton.pressed.connect(GameManager.switch_to_menu)
	enter_world_pressed.connect(GameManager.select_world)
	select_new_world(1, false)
	load_all_worlds()

func load_all_worlds() -> void:
	var i: int = 0
	while true:
		var world_scene_path: String = get_world_scene_path(i)
		if FileAccess.file_exists(world_scene_path):
			load_world(i)
		else:
			break
		i += 1

func load_world(world_number: int) -> void:
	var world_selection_button: WorldSelectionButton = world_selection_button_scene.instantiate()
	world_selection_button.change_world_number(world_number)
	world_selection_button.pressed.connect(select_new_world.bind(world_number, true))
	world_button_container.add_child(world_selection_button)

func get_world_scene_path(number: int) -> String:
	return "res://scenes/worlds/world_%d.tscn" % number

func select_new_world(world_number: int, play_tween: bool) -> void:
	if world_number == selected_world_number:
		return
	selected_world_number = world_number
	%SelectedWorldPanel.get_node("WorldNumberLabel").text = str(world_number)
	if play_tween:
		play_world_number_label_tween()

func _on_enter_world_button_pressed() -> void:
	enter_world_pressed.emit(selected_world_number)

func play_world_number_label_tween():
	if world_number_label_tween:
		world_number_label_tween.kill()
	world_number_label_tween = get_tree().create_tween()
	var label: Label = %SelectedWorldPanel.get_node("WorldNumberLabel")
	label.label_settings.font_size = 92
	world_number_label_tween.tween_property(label, "label_settings:font_size", 64, 0.25)
