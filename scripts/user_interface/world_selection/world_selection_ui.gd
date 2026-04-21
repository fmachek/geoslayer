class_name WorldSelectionUI
extends Control
## Represents UI where the player can select a [World] to enter.

## Emitted when the "Enter world" button is pressed.
signal enter_world_pressed(world_number: int)

const _BUTTON_SCENE := preload(
		"res://scenes/user_interface/world_selection/world_selection_button.tscn")

## The world number currently selected.
var selected_world_number: int = -1
var _world_number_label_tween: Tween

@onready var _world_button_container: HFlowContainer = %WorldButtonContainer
@onready var _enter_world_button: Button = %EnterWorldButton
@onready var _menu_button: Button = %BackToMenuButton
@onready var _selected_world_panel: Panel = %SelectedWorldPanel


func _ready() -> void:
	_enter_world_button.pressed.connect(_on_enter_world_button_pressed)
	_menu_button.pressed.connect(GameManager.switch_to_menu)
	enter_world_pressed.connect(GameManager.select_world)
	select_new_world(1, false)
	_load_all_worlds()


## Selects a new world with a given [param world_number].
## If [param play_tween] is [code]true[/code], a visual effect is played.
func select_new_world(world_number: int, play_tween: bool) -> void:
	if world_number == selected_world_number:
		return
	selected_world_number = world_number
	_selected_world_panel.get_node("WorldNumberLabel").text = str(world_number)
	if play_tween:
		_play_world_number_label_tween()


func _load_all_worlds() -> void:
	var i: int = 0
	while true:
		var world_scene_path: String = _get_world_scene_path(i)
		if ResourceLoader.exists(world_scene_path):
			if not i in WorldManager.hidden_worlds:
				_load_world(i)
		else:
			break
		i += 1


func _load_world(world_number: int) -> void:
	var button: WorldSelectionButton = _BUTTON_SCENE.instantiate()
	button.change_world_number(world_number)
	button.pressed.connect(select_new_world.bind(world_number, true))
	_world_button_container.add_child(button)


func _on_enter_world_button_pressed() -> void:
	enter_world_pressed.emit(selected_world_number)


func _play_world_number_label_tween():
	if _world_number_label_tween:
		_world_number_label_tween.kill()
	_world_number_label_tween = get_tree().create_tween()
	var label: Label = _selected_world_panel.get_node("WorldNumberLabel")
	label.label_settings.font_size = 92
	_world_number_label_tween.tween_property(label, "label_settings:font_size", 64, 0.25)


func _get_world_scene_path(number: int) -> String:
	return "res://scenes/worlds/world_%d.tscn" % number
