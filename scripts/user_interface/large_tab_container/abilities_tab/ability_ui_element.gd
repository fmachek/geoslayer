class_name AbilityUIElement
extends HBoxContainer
## Represents an unlocked [Ability] in the UI. Allows the player to equip
## or unequip it.

## Emitted when the "Equip in slot 1" button is pressed.
signal equip1_pressed(ability_name: String)
## Emitted when the "Equip in slot 2" button is pressed.
signal equip2_pressed(ability_name: String)

## Name of the [Ability].
var ability_name: String
## Reference to the player.
var player: PlayerCharacter
## Says which slot it's currently displaying, for example if the [Ability]
## is currently equipped in slot 1, the value will be 1. If the [Ability]
## isn't equipped, the value will be 0.
var displaying_slot: int = 0

@onready var _equip_button_1: Button = %EquipSlot1Button
@onready var _equip_button_2: Button = %EquipSlot2Button
@onready var _name_label: Label = %AbilityNameLabel
@onready var _equipped_label: Label = %EquippedLabel
@onready var _cd_label: Label = %CooldownLabel
@onready var _desc_label: Label = %DescriptionLabel
@onready var _texture_rect: TextureRect = %AbilityTextureRect
@onready var _highlight_panel: Panel = %HighlightPanel


func _ready() -> void:
	_connect_equip_events()


## Loads a [param player_char]'s unlocked [param ability].
func load_ability(ability: Ability, player_char: PlayerCharacter):
	ability_name = ability.get_ability_name()
	self.player = player_char
	_name_label.text = ability_name
	_texture_rect.texture = ability.texture
	_desc_label.text = ability.description
	_update_cooldown_label(ability.cooldown)
	player_char.ability1_changed.connect(_on_player_ability1_changed)
	player_char.ability2_changed.connect(_on_player_ability2_changed)
	_perform_first_slot_check()


func _check_equip_slot(new_ability: Ability, slot: int):
	if not new_ability:
		if displaying_slot == slot:
			# This means slot 1 is being displayed but was unequipped
			_change_slot(0)
	elif new_ability.get_ability_name() == ability_name:
		# This means that the player equipped this ability in slot 1.
		_change_slot(slot)
	elif displaying_slot == slot:
		# This means that the player equipped something else in slot 1.
		_change_slot(0) # Stop displaying as equipped in slot 1


func _perform_first_slot_check():
	if player.ability1:
		if player.ability1.get_ability_name() == ability_name:
			_change_slot(1)
	elif player.ability2:
		if player.ability2.get_ability_name() == ability_name:
			_change_slot(2)


func _change_slot(new_slot: int):
	displaying_slot = new_slot
	if new_slot == 0:
		_equipped_label.hide()
		_highlight_panel.hide()
		_equip_button_1.disabled = false
		_equip_button_2.disabled = false
	else:
		_equipped_label.text = "Equipped in slot %d" % new_slot
		_equipped_label.show()
		_highlight_panel.show()
		if new_slot == 1:
			_equip_button_1.disabled = true
			_equip_button_2.disabled = false
		elif new_slot == 2:
			_equip_button_1.disabled = false
			_equip_button_2.disabled = true


func _connect_equip_events():
	equip1_pressed.connect(PlayerManager._on_UI_ability1_equip)
	equip2_pressed.connect(PlayerManager._on_UI_ability2_equip)


func _on_player_ability1_changed(new_ability: Ability):
	_check_equip_slot(new_ability, 1)


func _on_player_ability2_changed(new_ability: Ability):
	_check_equip_slot(new_ability, 2)


func _on_equip_slot_1_button_pressed() -> void:
	equip1_pressed.emit(ability_name)


func _on_equip_slot_2_button_pressed() -> void:
	equip2_pressed.emit(ability_name)


func _update_cooldown_label(cooldown: float) -> void:
	_cd_label.text = "Cooldown: " + str(cooldown) + " seconds"
