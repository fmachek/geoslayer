extends Node

signal player_spawned(player: PlayerCharacter)
signal player_died(player: PlayerCharacter)
signal perk_points_changed(points: int)

var player_scene := preload("res://scenes/characters/player/player_character.tscn")
var current_player: PlayerCharacter

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func spawn_player(pos: Vector2):
	current_player = player_scene.instantiate()
	WorldManager.current_world.add_child(current_player)
	current_player.name = "PlayerCharacter"
	current_player.global_position = pos
	connect_player_signals()
	player_spawned.emit(current_player)

func connect_player_signals():
	current_player.died.connect(_on_player_died)
	current_player.died.connect(GameManager._on_player_died)
	current_player.perk_points_available_changed.connect(func(points: int): perk_points_changed.emit(points))

func _on_player_died():
	player_died.emit(current_player)
	current_player.died.disconnect(_on_player_died)

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

func apply_perk_point(stat: CharacterStat) -> void:
	if current_player:
		current_player.apply_perk_point(stat)
