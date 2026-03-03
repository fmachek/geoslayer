class_name UserInterface
extends Control

func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)

func _on_player_spawned(player: PlayerCharacter):
	load_new_player(player)

func load_new_player(player: PlayerCharacter):
	connect_player_signals(player)
	%AbilityItem1.load_ability(player.ability1)
	%AbilityItem2.load_ability(player.ability2)

func connect_player_signals(player: PlayerCharacter):
	player.died.connect(_on_player_died)
	player.ability1_changed.connect(_on_ability1_changed)
	player.ability2_changed.connect(_on_ability2_changed)

func _on_ability1_changed(new_ability: Ability):
	%AbilityItem1.load_ability(new_ability)

func _on_ability2_changed(new_ability: Ability):
	%AbilityItem2.load_ability(new_ability)

func _on_player_died():
	pass
