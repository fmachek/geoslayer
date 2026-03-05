class_name World
extends Node2D

var player_spawn_pos: Vector2
@onready var wave_manager: WaveManager = $WaveManager

func _ready() -> void:
	player_spawn_pos = %PlayerSpawnPoint.global_position
	call_deferred("spawn_player")

func spawn_player():
	PlayerManager.spawn_player(player_spawn_pos)

func start_wave():
	wave_manager.start_wave()
