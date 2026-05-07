class_name UserInterface
extends Control
## Represents the in-game UI.

var _label_size_tween: Tween
var _label_opacity_tween: Tween

@onready var ability_item_1: AbilityItem = %AbilityItem1
@onready var ability_item_2: AbilityItem = %AbilityItem2
@onready var _boss_defeated_label: Label = %BossDefeatedLabel


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)
	WorldManager.boss_died.connect(_show_boss_defeated_label)


func _load_new_player(player: PlayerCharacter):
	_connect_player_signals(player)
	ability_item_1.load_ability(player.ability1)
	ability_item_2.load_ability(player.ability2)


func _connect_player_signals(player: PlayerCharacter):
	player.died.connect(hide)
	player.ability1_changed.connect(_on_ability1_changed)
	player.ability2_changed.connect(_on_ability2_changed)


func _on_player_spawned(player: PlayerCharacter):
	_load_new_player(player)


func _on_ability1_changed(new_ability: Ability):
	ability_item_1.load_ability(new_ability)


func _on_ability2_changed(new_ability: Ability):
	ability_item_2.load_ability(new_ability)


func _show_boss_defeated_label() -> void:
	_boss_defeated_label.show()
	_play_boss_defeated_label_tween()


func _play_boss_defeated_label_tween() -> void:
	if _label_size_tween:
		_label_size_tween.kill()
	_boss_defeated_label.scale = Vector2(2, 2)
	_label_size_tween = create_tween()
	_label_size_tween.tween_property(
			_boss_defeated_label, "scale", Vector2.ONE, 0.25
	)
	_label_size_tween.tween_callback(_boss_defeated_label_fade_out).set_delay(3.0)


func _boss_defeated_label_fade_out() -> void:
	if _label_opacity_tween:
		_label_opacity_tween.kill()
	_label_opacity_tween = create_tween()
	_boss_defeated_label.modulate.a = 1
	_label_opacity_tween.tween_property(
			_boss_defeated_label, "modulate:a", 0, 0.5
	)
	_label_opacity_tween.tween_callback(_boss_defeated_label.hide)


func _on_pause_interface_hidden() -> void:
	show()


func _on_pause_interface_showed() -> void:
	hide()
