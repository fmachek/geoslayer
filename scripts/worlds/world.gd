class_name World
extends Node2D

var player_spawn_pos: Vector2
@onready var wave_manager: WaveManager = $WaveManager

@export var chest_scene: PackedScene = preload("res://scenes/characters/containers/chest.tscn")
## Amount of XP granted by each [XPOrb] dropped in the [World].
@export var xp_per_orb: int = 30
var unopened_chests: Array = []

func _ready() -> void:
	wave_manager.wave_ended.connect(_handle_wave_end)
	player_spawn_pos = %PlayerSpawnPoint.global_position
	XPOrb.xp_amount = xp_per_orb
	call_deferred("spawn_player")

func spawn_player():
	PlayerManager.spawn_player(player_spawn_pos)

func start_wave():
	wave_manager.start_wave()

func spawn_chest() -> void:
	var chest: Chest = chest_scene.instantiate()
	chest.show_info_label("Wave %d reward" % wave_manager.current_wave)
	chest.xp_amount = wave_manager.current_wave * 3
	chest.died.connect(_on_chest_opened.bind(chest))
	if unopened_chests.is_empty():
		add_child(chest)
		chest.global_position = %ChestSpawnPoint.global_position
	unopened_chests.append(chest)

func _on_chest_opened(chest: Chest) -> void:
	unopened_chests.erase(chest)
	if not unopened_chests.is_empty(): # Spawn another chest
		var new_chest: Chest = unopened_chests[0]
		add_child(new_chest)
		new_chest.global_position = %ChestSpawnPoint.global_position

func _handle_wave_end() -> void:
	if wave_manager.current_wave == wave_manager.max_waves:
		return
	spawn_chest()
