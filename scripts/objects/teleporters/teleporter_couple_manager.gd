class_name TeleporterCoupleManager
extends Node2D
## Represents a node which links two [Teleporter]s and manages
## their cooldown.
##
## [member teleporter_1] and [member teleporter_2] must be set and they
## must be two different instances.

## Emitted when the cooldown starts.
signal cooldown_started()
## Emitted when the cooldown ends.
signal cooldown_ended()

## Time which must pass between uses of the [Teleporter] link in seconds.
@export var cooldown: float = 5.0
## The first [Teleporter]. Must be different from [member teleporter_2].
@export var teleporter_1: Teleporter
## The second [Teleporter]. Must be different from [member teleporter_1].
@export var teleporter_2: Teleporter

## Says if the [Teleporter] link is on cooldown or not. When it is,
## it cannot be used.
var is_on_cooldown: bool = false: set = _set_is_on_cooldown

@onready var _cd_timer: Timer = $CooldownTimer


func _ready() -> void:
	if not (is_instance_valid(teleporter_1) and is_instance_valid(teleporter_2)):
		print("Teleporter couple is incomplete.")
		return
	if teleporter_1 == teleporter_2:
		print("Teleporter couple has both teleporters set to the same instance.")
		return
	teleporter_1.player_entered.connect(_handle_teleport_1)
	teleporter_2.player_entered.connect(_handle_teleport_2)
	_cd_timer.timeout.connect(_on_cd_timer_timeout)
	cooldown_started.connect(_update_teleporter_cooldown)
	cooldown_ended.connect(_update_teleporter_cooldown)
	_cd_timer.wait_time = cooldown


func _handle_teleport_1(player: PlayerCharacter) -> void:
	_teleport_player(player, teleporter_2)


func _handle_teleport_2(player: PlayerCharacter) -> void:
	_teleport_player(player, teleporter_1)


func _teleport_player(player: PlayerCharacter, teleporter: Teleporter) -> void:
	var target_pos: Vector2 = teleporter.global_position
	player.global_position = target_pos
	is_on_cooldown = true
	_cd_timer.start()
	teleporter_1.play_particles()
	teleporter_2.play_particles()


func _on_cd_timer_timeout() -> void:
	is_on_cooldown = false


func _update_teleporter_cooldown() -> void:
	teleporter_1.is_on_cooldown = is_on_cooldown
	teleporter_2.is_on_cooldown = is_on_cooldown
	if is_on_cooldown:
		teleporter_1.play_progress_bar_effect(cooldown)
		teleporter_2.play_progress_bar_effect(cooldown)


func _set_is_on_cooldown(value: bool) -> void:
	is_on_cooldown = value
	if value:
		cooldown_started.emit()
	else:
		cooldown_ended.emit()
