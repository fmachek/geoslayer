class_name AbilitiesTab
extends PanelContainer
## Represents a tab in the UI where the player can equip and unequip
## abilities.

## Emitted when the "Unequip slot 1" button is pressed.
signal unequip_slot1_pressed()
## Emitted when the "Unequip slot 2" button is pressed.
signal unequip_slot2_pressed()
## Emitted when the "Unequip all" button is pressed.
signal unequip_all_pressed()

const _ABILITY_ELEMENT_SCENE := preload(
		"res://scenes/user_interface/abilities_tab/ability_ui_element.tscn")
## A reference to the [PlayerCharacter].
var player: PlayerCharacter
@onready var _ability_container: VBoxContainer = %AbilityContainer


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)
	PlayerManager.player_died.connect(_on_player_died)
	unequip_slot1_pressed.connect(PlayerManager._on_UI_unequip_slot1_pressed)
	unequip_slot2_pressed.connect(PlayerManager._on_UI_unequip_slot2_pressed)
	unequip_all_pressed.connect(PlayerManager._on_UI_unequip_all_pressed)


## Loads an [AbilityUIElement] for every [Ability] unlocked
## by the player.
func load_unlocked_abilities():
	var unlocked_abilities = player.unlocked_abilities
	for ability: Ability in unlocked_abilities:
		load_unlocked_ability(ability)


## Loads an [AbilityUIElement] for a given [param ability].
func load_unlocked_ability(ability: Ability):
	var ability_ui_element: AbilityUIElement = _ABILITY_ELEMENT_SCENE.instantiate()
	_ability_container.add_child(ability_ui_element)
	ability_ui_element.load_ability(ability, player)


func _on_player_spawned(player: PlayerCharacter):
	self.player = player
	player.new_ability_unlocked.connect(load_unlocked_ability)
	load_unlocked_abilities()


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
	for element in _ability_container.get_children():
		element.queue_free()
