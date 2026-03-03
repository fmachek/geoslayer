extends Node

signal player_spawned(player: PlayerCharacter)
signal player_died(player: PlayerCharacter)

var player_scene := preload("res://scenes/characters/player/player_character.tscn")
var current_player: PlayerCharacter

func spawn_player(pos: Vector2):
	current_player = player_scene.instantiate()
	WorldManager.current_world.add_child(current_player)
	current_player.name = "PlayerCharacter"
	current_player.global_position = pos
	connect_player_signals()
	player_spawned.emit(current_player)

func connect_player_signals():
	current_player.died.connect(_on_player_died)

func _on_player_died():
	player_died.emit(current_player)
	current_player.died.disconnect(_on_player_died)
	spawn_player(WorldManager.current_world.player_spawn_pos)

func _on_UI_ability1_equip(ability_name: String):
	if not current_player:
		return
	for ability in current_player.unlocked_abilities:
		if ability.ability_name == ability_name:
			current_player.replace_ability1(ability)

func _on_UI_ability2_equip(ability_name: String):
	if not current_player:
		return
	for ability in current_player.unlocked_abilities:
		if ability.ability_name == ability_name:
			current_player.replace_ability2(ability)

func _on_UI_unequip_slot1_pressed():
	if not current_player:
		return
	current_player.replace_ability1(null)

func _on_UI_unequip_slot2_pressed():
	if not current_player:
		return
	current_player.replace_ability2(null)

func _on_UI_unequip_all_pressed():
	if not current_player:
		return
	current_player.replace_ability1(null)
	current_player.replace_ability2(null)
