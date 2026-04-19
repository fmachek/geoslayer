class_name Main
extends Node2D
## Represents the root in-game node.

var _death_cam_tween: Tween
## Camera used when the player dies.
@onready var death_cam: Camera2D = $DeathCamera


func _ready() -> void:
	# Chest ability pool must be cleared between runs
	Chest.clear_ability_pool()
	PlayerManager.player_died.connect(_on_player_died)


## Plays a visual effect where the [member death_cam]
## zooms into the player's position of death.
func play_death_cam_tween() -> void:
	death_cam.zoom = Vector2(1, 1)
	if _death_cam_tween:
		_death_cam_tween.kill()
	_death_cam_tween = get_tree().create_tween()
	_death_cam_tween.set_ease(Tween.EASE_OUT)
	_death_cam_tween.set_trans(Tween.TRANS_ELASTIC)
	var end_zoom := Vector2(1.5, 1.5)
	_death_cam_tween.tween_property(death_cam, "zoom", end_zoom, 3)
	_death_cam_tween.play()


func _on_player_died(player: PlayerCharacter) -> void:
	death_cam.enabled = true
	death_cam.global_position = player.global_position
	play_death_cam_tween()
