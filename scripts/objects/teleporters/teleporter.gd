class_name Teleporter
extends Node2D
## Represents an object which teleports a [PlayerCharacter] to another
## [Teleporter] when they step into it.
##
## A [TeleporterCoupleManager] must be used to link two [Teleporter]s and
## manage their cooldown.

## Emitted when a [PlayerCharacter] is detected by the [Area2D].
signal player_entered(player: PlayerCharacter)
## Emitted when the cooldown starts.
signal cooldown_started()
## Emitted when the cooldown ends.
signal cooldown_ended()

## Says if the [Teleporter] is on cooldown or not. It cannot be used
## when it is on cooldown.
var is_on_cooldown: bool = false: set = _set_is_on_cooldown
var _texture: Texture2D = preload(
		"res://assets/sprites/objects/teleporters/teleporter.png")
var _depleted_texture: Texture2D = preload(
		"res://assets/sprites/objects/teleporters/depleted_teleporter.png")
var _bar_tween: Tween

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _area: Area2D = $DetectionArea
@onready var _particles: CPUParticles2D = $TeleportParticles
@onready var _progress_bar: ProgressBar = $CooldownProgressBar


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	cooldown_ended.connect(_check_overlap)
	cooldown_started.connect(_update_texture)
	cooldown_ended.connect(_update_texture)


## Starts emitting particles.
func play_particles() -> void:
	_particles.emitting = true


## Shows a [ProgressBar] which shows cooldown progress. The value
## of the [ProgressBar] is tweened and it disappears when it finishes.
func play_progress_bar_effect(cooldown: float) -> void:
	if _bar_tween:
		_bar_tween.kill()
	_progress_bar.value = 0
	_progress_bar.show()
	
	_bar_tween = create_tween()
	_bar_tween.tween_property(_progress_bar, "value", 100, cooldown)
	_bar_tween.tween_callback(_progress_bar.hide)


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter and not is_on_cooldown:
		player_entered.emit(body)


# Checks for player standing inside the teleporter, used
# when the cooldown ends
func _check_overlap() -> void:
	var bodies: Array[Node2D] = _area.get_overlapping_bodies()
	for body in bodies:
		if body is PlayerCharacter:
			player_entered.emit(body)
			return


func _update_texture() -> void:
	if is_on_cooldown:
		_sprite.texture = _depleted_texture
	else:
		_sprite.texture = _texture


func _set_is_on_cooldown(value: bool) -> void:
	is_on_cooldown = value
	if value:
		cooldown_started.emit()
	else:
		cooldown_ended.emit()
