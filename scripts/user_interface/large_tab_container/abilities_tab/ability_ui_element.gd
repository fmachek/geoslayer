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
@onready var _cast_time_label: Label = %CastTimeLabel
@onready var _texture_rect: TextureRect = %AbilityTextureRect
@onready var _highlight_panel: Panel = %HighlightPanel


func _ready() -> void:
	_connect_equip_events()
	WorldManager.wave_started.connect(_disable_buttons)
	WorldManager.wave_ended.connect(_enable_buttons)


## Loads a [param player_char]'s unlocked [param ability].
func load_ability(ability: Ability, player_char: PlayerCharacter):
	ability_name = ability.get_ability_name()
	self.player = player_char
	_name_label.text = ability_name
	_texture_rect.texture = ability.texture
	_desc_label.text = ability.description
	_update_cooldown_label(ability.cooldown)
	_update_cast_time_label(ability.cast_time)
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
		_enable_button(_equip_button_1)
		_enable_button(_equip_button_2)
	else:
		_equipped_label.text = "Equipped in slot %d" % new_slot
		_equipped_label.show()
		_highlight_panel.show()
		if new_slot == 1:
			_enable_button(_equip_button_2)
			_disable_button(_equip_button_1)
		elif new_slot == 2:
			_enable_button(_equip_button_1)
			_disable_button(_equip_button_2)


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
	var new_text: String = "Cooldown: " + str(cooldown)
	if cooldown <= 1.0:
		new_text += " second"
	else:
		new_text += " seconds"
	_cd_label.text = new_text


func _update_cast_time_label(cast_time: float) -> void:
	if cast_time == 0.0:
		_cast_time_label.text = "Cast duration: instant"
		return
	
	var new_text: String = "Cast duration: " + str(cast_time)
	if cast_time <= 1.0:
		new_text += " second"
	else:
		new_text += " seconds"
	_cast_time_label.text = new_text


func _disable_button(button: Button) -> void:
	button.disabled = true
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW


func _enable_button(button: Button) -> void:
	button.disabled = false
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _disable_buttons() -> void:
	_disable_button(_equip_button_1)
	_disable_button(_equip_button_2)


func _enable_buttons() -> void:
	if displaying_slot == 0:
		_enable_button(_equip_button_1)
		_enable_button(_equip_button_2)
	elif displaying_slot == 1:
		_enable_button(_equip_button_2)
	elif displaying_slot == 2:
		_enable_button(_equip_button_1)
