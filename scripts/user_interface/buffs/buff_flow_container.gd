class_name BuffFlowContainer
extends HFlowContainer

const BUFF_ELEMENT_SCENE := preload(
	"res://scenes/user_interface/buffs/buff_ui_element.tscn"
)


func _ready() -> void:
	SignalBus.applied_buff_to_player.connect(create_buff_element)


func create_buff_element(buff: Buff) -> void:
	var buff_element: BuffUIElement = BUFF_ELEMENT_SCENE.instantiate()
	buff_element.buff = buff
	add_child(buff_element)
