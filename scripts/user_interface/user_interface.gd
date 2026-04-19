class_name UserInterface
extends Control
## Represents the in-game UI.

@onready var ability_item_1: AbilityItem = %AbilityItem1
@onready var ability_item_2: AbilityItem = %AbilityItem2


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)


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
