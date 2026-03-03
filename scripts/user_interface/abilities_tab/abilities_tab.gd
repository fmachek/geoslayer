class_name AbilitiesTab
extends Panel

var player: PlayerCharacter
var ability_ui_element_scene := preload("res://scenes/user_interface/abilities_tab/ability_ui_element.tscn")

signal unequip_slot1_pressed()
signal unequip_slot2_pressed()
signal unequip_all_pressed()

func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)
	PlayerManager.player_died.connect(_on_player_died)
	unequip_slot1_pressed.connect(PlayerManager._on_UI_unequip_slot1_pressed)
	unequip_slot2_pressed.connect(PlayerManager._on_UI_unequip_slot2_pressed)
	unequip_all_pressed.connect(PlayerManager._on_UI_unequip_all_pressed)

func _on_player_spawned(player: PlayerCharacter):
	self.player = player
	player.new_ability_unlocked.connect(load_unlocked_ability)
	load_unlocked_abilities()

func load_unlocked_abilities():
	var unlocked_abilities = player.unlocked_abilities
	for ability: Ability in unlocked_abilities:
		load_unlocked_ability(ability)

func load_unlocked_ability(ability: Ability):
	var ability_ui_element := ability_ui_element_scene.instantiate()
	%AbilityContainer.add_child(ability_ui_element)
	ability_ui_element.load_ability(ability, player)

func _on_unequip_slot_1_button_pressed() -> void:
	unequip_slot1_pressed.emit()

func _on_unequip_slot_2_button_pressed() -> void:
	unequip_slot2_pressed.emit()

func _on_unequip_all_button_pressed() -> void:
	unequip_all_pressed.emit()

func _on_abilities_tab_open_button_pressed() -> void:
	show()

func _on_close_button_pressed() -> void:
	hide()

func _on_player_died(player: PlayerCharacter):
	for element in %AbilityContainer.get_children():
		element.queue_free()
