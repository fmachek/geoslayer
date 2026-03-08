class_name Main
extends Node2D

var death_cam_tween: Tween
@onready var death_cam: Camera2D = $DeathCamera

func _ready() -> void:
	PlayerManager.player_died.connect(_on_player_died)

func _on_player_died(player: PlayerCharacter) -> void:
	death_cam.enabled = true
	death_cam.global_position = player.global_position
	play_death_cam_tween()

func play_death_cam_tween() -> void:
	death_cam.zoom = Vector2(1, 1)
	if death_cam_tween:
		death_cam_tween.kill()
	death_cam_tween = get_tree().create_tween()
	death_cam_tween.set_ease(Tween.EASE_OUT)
	death_cam_tween.set_trans(Tween.TRANS_ELASTIC)
	death_cam_tween.tween_property(death_cam, "zoom", Vector2(1.5, 1.5), 3)
	death_cam_tween.play()
