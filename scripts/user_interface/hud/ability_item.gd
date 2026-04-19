class_name AbilityItem
extends TextureRect
## Represents an equipped [Ability] in the HUD. Can cast the [Ability]
## when pressed.

## Emitted when pressed.
signal cast()

## Ability currently being displayed.
var current_ability: Ability
var _cooldown_tween: Tween

@onready var _cooldown_rect = $CooldownRect


## Loads a given [param ability].
func load_ability(ability: Ability):
	if not ability:
		hide()
		_stop_cooldown_tween()
		return
	else:
		show()
	if current_ability:
		_disconnect_ability_signals()
	current_ability = ability
	_connect_ability_signals()
	_stop_cooldown_tween()
	texture = ability.texture


func _play_cooldown_tween():
	if not current_ability:
		return
	_cooldown_rect.size.y = size.y
	if _cooldown_tween:
		_cooldown_tween.kill()
	_cooldown_tween = get_tree().create_tween()
	_cooldown_tween.tween_property(_cooldown_rect, "size:y", 0, current_ability.cooldown)


func _stop_cooldown_tween():
	if _cooldown_tween:
		_cooldown_tween.kill()
	_cooldown_rect.size.y = 0


func _on_ability_cooldown_ended():
	_stop_cooldown_tween()


func _connect_ability_signals():
	current_ability.casted.connect(_play_cooldown_tween)
	current_ability.cooldown_ended.connect(_on_ability_cooldown_ended)
	cast.connect(current_ability.cast)


func _disconnect_ability_signals():
	current_ability.casted.disconnect(_play_cooldown_tween)
	current_ability.cooldown_ended.disconnect(_on_ability_cooldown_ended)
	cast.disconnect(current_ability.cast)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cast.emit()
