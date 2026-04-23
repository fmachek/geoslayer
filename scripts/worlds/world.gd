class_name World
extends Node2D
## Represents an in-game world where enemies come in waves.
##
## The [World] spawns [Chest]s when a wave ends. If the player doesn't open
## the [Chest], they stack up in the background. If the player opens it later,
## another unopened [Chest] will spawn. That essentially works as a queue for [Chest]s.

## Scene of the [Chest] dropped when a wave ends.
@export var chest_scene: PackedScene = load(
		"res://scenes/characters/containers/chest.tscn")
## Amount of XP granted by each [XPOrb] dropped in the [World].
@export var xp_per_orb: int = 30

var _player_spawn_pos: Vector2
var _unopened_chests: Array = []

@onready var wave_manager: WaveManager = $WaveManager
@onready var _player_spawn_point: Node2D = %PlayerSpawnPoint
@onready var _chest_spawn_point: Node2D = %ChestSpawnPoint


func _ready() -> void:
	wave_manager.wave_ended.connect(_handle_wave_end)
	_player_spawn_pos = _player_spawn_point.global_position
	XPOrb.xp_amount = xp_per_orb
	call_deferred("spawn_player")


## Triggers a player spawn.
func spawn_player():
	PlayerManager.spawn_player(_player_spawn_pos)


## Triggers a wave start.
func start_wave():
	wave_manager.start_wave()


## Spawns an instance of [member chest_scene].
func spawn_chest() -> void:
	var chest: Chest = chest_scene.instantiate()
	chest.show_info_label("Wave %d reward" % wave_manager.current_wave)
	chest.xp_amount = wave_manager.current_wave * 3
	chest.died.connect(_on_chest_opened.bind(chest))
	if _unopened_chests.is_empty():
		add_child(chest)
		chest.global_position = _chest_spawn_point.global_position
	_unopened_chests.append(chest)


func _on_chest_opened(chest: Chest) -> void:
	_unopened_chests.erase(chest)
	if not _unopened_chests.is_empty(): # Spawn another chest
		var new_chest: Chest = _unopened_chests[0]
		add_child(new_chest)
		new_chest.global_position = _chest_spawn_point.global_position


func _handle_wave_end() -> void:
	if wave_manager.current_wave == wave_manager.max_waves:
		return
	spawn_chest()
