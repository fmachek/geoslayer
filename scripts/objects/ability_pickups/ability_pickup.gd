class_name AbilityPickup
extends Node2D
## Represents an object a [PlayerCharacter] can pick up to unlock an [Ability].

const _PARTICLE_SCENE := preload(
		"res://scenes/particle_effects/ability_pickup_particles.tscn")

## Emitted when picked up by a [PlayerCharacter].
signal picked_up()

const _LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/ability_pickup_label.tscn")
	
## Fill color of the shape.
@export var draw_color := Color.GRAY
## Outline color of the shape.
@export var outline_color := Color.DIM_GRAY
## Script used to instantiate the new unlocked [Ability].
@export var ability_script: Resource
## Speed at which the [AbilityPickup] is rotating on every frame.
@export var rot_speed: float = 3.0
## Amount of XP given to the [PlayerCharacter] on pick up if they
## have unlocked the [Ability] already.
@export var fallback_xp: int = 50
# Ability name which is the same as the name of the Ability script.
var _ability_name: String
# True if the pickup has already been picked up.
var _was_picked_up := false
# Used to tween scale and transparency.
var _tween: Tween


func _ready() -> void:
	var path: String = ability_script.resource_path
	_ability_name = path.get_file().get_basename().capitalize()
	_spawn_label()


func _process(delta: float) -> void:
	global_rotation += rot_speed * delta


# Draws a square shape.
func _draw() -> void:
	var col_shape: CollisionShape2D = $Area2D/CollisionShape2D
	var shape = col_shape.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var rect := Rect2(-width / 2, -height / 2, width, height)
	var outline_width: float = 4.0
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, outline_width)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _was_picked_up or body is not PlayerCharacter:
		return
	picked_up.emit()
	_unlock_ability(body)


# Attempts to unlock a new Ability for a PlayerCharacter.
# If the Ability is already unlocked, the PlayerCharacter is given
# fallback XP instead.
func _unlock_ability(player: PlayerCharacter) -> void:
	var ability: Ability = ability_script.new()
	if ability:
		if player.unlock_new_ability(ability):
			_spawn_particles()
		else:
			 # Fallback XP reward if the player already has the ability
			player.level.add_xp(fallback_xp)
		_play_tween()


# Plays a scale and transparency tween and when the tween finishes, the
# AbilityPickup is freed.
func _play_tween() -> void:
	var tween_time: float = 0.25
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ZERO, tween_time)
	_tween.parallel().tween_property(self, "modulate:a", 0, tween_time)
	_tween.tween_callback(queue_free)


func _spawn_label() -> void:
	var label: AbilityPickupLabel = _LABEL_SCENE.instantiate()
	label.text = _ability_name
	label.global_position = global_position - Vector2(label.size.x / 2, 60)
	picked_up.connect(label.fade_out)
	get_parent().call_deferred("add_child", label)


func _spawn_particles() -> void:
	var particles: AbilityPickupParticles = _PARTICLE_SCENE.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.play()
