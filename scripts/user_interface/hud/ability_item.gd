class_name AbilityItem
extends TextureRect

var cooldown_tween: Tween
var ability_cooldown: float
var current_ability: Ability

signal cast()

@onready var cooldown_rect = $CooldownRect
@export var key = "Q"

func _ready() -> void:
	$KeyLabel.text = key.capitalize()

func play_cooldown_tween():
	if not current_ability:
		return
	cooldown_rect.size.y = size.y
	if cooldown_tween:
		cooldown_tween.kill()
	cooldown_tween = get_tree().create_tween()
	cooldown_tween.tween_property(cooldown_rect, "size:y", 0, ability_cooldown)

func load_ability(ability: Ability):
	if not ability:
		hide()
		stop_cooldown_tween()
		return
	else:
		show()
	if current_ability:
		disconnect_ability_signals()
	current_ability = ability
	ability_cooldown = current_ability.cooldown
	connect_ability_signals()
	stop_cooldown_tween()
	texture = ability.texture

func stop_cooldown_tween():
	if cooldown_tween:
		cooldown_tween.kill()
	cooldown_rect.size.y = 0

func _on_ability_cooldown_ended():
	stop_cooldown_tween()

func connect_ability_signals():
	current_ability.casted.connect(play_cooldown_tween)
	current_ability.cooldown_ended.connect(_on_ability_cooldown_ended)
	cast.connect(current_ability.cast)

func disconnect_ability_signals():
	current_ability.casted.disconnect(play_cooldown_tween)
	current_ability.cooldown_ended.disconnect(_on_ability_cooldown_ended)
	cast.disconnect(current_ability.cast)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cast.emit()
