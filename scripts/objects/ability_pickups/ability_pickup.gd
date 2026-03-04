class_name AbilityPickup
extends Node2D

@export var draw_color: Color = Color.GRAY # Fill draw color
@export var outline_color: Color = Color.DIM_GRAY # Outline draw color

@export var ability_script: Resource
var ability_name: String

var was_picked_up: bool = false

var size_tween: Tween
var rot_speed = 3

var label_scene := preload("res://scenes/user_interface/world_labels/ability_pickup_label.tscn")

signal picked_up()

func _process(delta: float) -> void:
	global_rotation += rot_speed*delta

func _ready():
	var path = ability_script.resource_path
	ability_name = path.get_file().get_basename().capitalize()
	spawn_label()

func _draw():
	var width = $Area2D/CollisionShape2D.shape.size.x
	var height = $Area2D/CollisionShape2D.shape.size.y
	draw_rect(Rect2(-width/2, -height/2, width, height), draw_color)
	draw_rect(Rect2(-width/2, -height/2, width, height), outline_color, false, 4)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if was_picked_up:
		return
	if body is PlayerCharacter:
		picked_up.emit()
		unlock_ability(body)

func unlock_ability(player: PlayerCharacter) -> void:
	var ability = ability_script.new()
	if ability:
		if player.unlock_new_ability(ability):
			$PickupParticles.emitting = true
			# Plays only if the ability is actually unlocked
		else:
			player.level.add_xp(30) # Fallback XP reward if the player already has the ability
		size_tween = create_tween()
		size_tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
		size_tween.parallel().tween_property(self, "modulate:a", 0, 0.25)
		size_tween.tween_callback(queue_free)

func spawn_label():
	var label: AbilityPickupLabel = label_scene.instantiate()
	label.text = ability_name
	label.global_position = global_position - Vector2(label.size.x/2, 60)
	picked_up.connect(label.fade_out)
	get_parent().call_deferred("add_child", label)
