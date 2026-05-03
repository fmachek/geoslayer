class_name StatPointDrop
extends Node2D
## Represents an object which the [PlayerCharacter] can pick up.
## The user then gains one permanent stat point.

## Emitted when picked up by a [PlayerCharacter].
signal picked_up()

const _PARTICLE_SCENE := preload(
		"res://scenes/particle_effects/stat_point_drop_particles.tscn")

## Says if the [StatPointDrop] has been picked up or not.
var was_picked_up: bool = false
var _body_deleted: bool = false
var _label_deleted: bool = false

@onready var _body: Node2D = get_node("Body")
@onready var _label: Label = get_node("PermanentStatPointLabel")


func _ready() -> void:
	picked_up.connect(UserManager.add_stat_point)
	picked_up.connect(_label_fade_out)
	picked_up.connect(_fade_out)
	picked_up.connect(_spawn_particles)
	_body.tree_exited.connect(_delete_body)
	_label.tree_exited.connect(_delete_label)


## Emits [signal picked_up] if [member was_picked_up] is false.
func pick_up() -> void:
	if was_picked_up:
		return
	was_picked_up = true
	picked_up.emit()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		if not was_picked_up:
			pick_up()


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_body, "modulate:a", 0, 0.15)
	tween.tween_callback(_body.queue_free)


func _label_fade_out() -> void:
	var tween := _label.create_tween()
	tween.tween_property(_label, "modulate:a", 0, 0.5)
	tween.tween_callback(_label.queue_free)


func _spawn_particles() -> void:
	var parent = get_parent()
	if is_instance_valid(parent):
		var particles: FreeParticles = _PARTICLE_SCENE.instantiate()
		particles.global_position = global_position
		parent.add_child(particles)
		particles.emitting = true


func _delete_body() -> void:
	_body_deleted = true
	_body = null
	if _label == null:
		queue_free()


func _delete_label() -> void:
	_label_deleted = true
	_label = null
	if _body == null:
		queue_free()
