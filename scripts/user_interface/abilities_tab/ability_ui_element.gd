class_name AbilityUIElement
extends HBoxContainer

var ability_name: String
var player: PlayerCharacter
var displaying_slot: int = 0

@onready var name_label = %AbilityNameLabel
@onready var equipped_label = %EquippedLabel

signal equip1_pressed(ability_name: String)
signal equip2_pressed(ability_name: String)

func _ready() -> void:
	connect_equip_events()

func connect_equip_events():
	equip1_pressed.connect(PlayerManager._on_UI_ability1_equip)
	equip2_pressed.connect(PlayerManager._on_UI_ability2_equip)

func load_ability(ability: Ability, player: PlayerCharacter):
	ability_name = ability.get_ability_name()
	self.player = player
	name_label.text = ability_name
	$TextureRect.texture = ability.texture
	%DescriptionLabel.text = ability.description
	player.ability1_changed.connect(_on_player_ability1_changed)
	player.ability2_changed.connect(_on_player_ability2_changed)
	
	first_slot_check()

func _on_player_ability1_changed(new_ability: Ability):
	check_equip_slot(new_ability, 1)

func _on_player_ability2_changed(new_ability: Ability):
	check_equip_slot(new_ability, 2)

func check_equip_slot(new_ability: Ability, slot: int):
	if not new_ability:
		if displaying_slot == slot:
			# This means slot 1 is being displayed but was unequipped
			change_slot(0)
	elif new_ability.get_ability_name() == ability_name:
		# This means that the player equipped this ability in slot 1.
		change_slot(slot)
	elif displaying_slot == slot:
		# This means that the player equipped something else in slot 1.
		change_slot(0) # Stop displaying as equipped in slot 1

func change_slot(new_slot: int):
	displaying_slot = new_slot
	if new_slot == 0:
		equipped_label.hide()
		%EquipSlot1Button.disabled = false
		%EquipSlot2Button.disabled = false
	else:
		equipped_label.text = "Equipped in slot " + str(new_slot)
		equipped_label.show()
		if new_slot == 1:
			%EquipSlot1Button.disabled = true
			%EquipSlot2Button.disabled = false
		elif new_slot == 2:
			%EquipSlot1Button.disabled = false
			%EquipSlot2Button.disabled = true

func _on_equip_slot_1_button_pressed() -> void:
	equip1_pressed.emit(ability_name)

func _on_equip_slot_2_button_pressed() -> void:
	equip2_pressed.emit(ability_name)

func first_slot_check():
	if player.ability1:
		if player.ability1.get_ability_name() == ability_name:
			change_slot(1)
	elif player.ability2:
		if player.ability2.get_ability_name() == ability_name:
			change_slot(2)
