class_name InstantDamageArea
extends InstantArea
## Represents an [InstantArea] which deals damage to [Character]s
## standing inside it.
##
## It has a [Sprite2D] which is randomly flipped horizontally and vertically
## and it scales to display the [InstantDamageArea]'s size properly.

const _DMG_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/damage_label.tscn")

## Amount of damage dealt to [Character]s.
var damage: int

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	super()
	_update_sprite()


func _perform(body: Node2D) -> void:
	if body is Character:
		var damage_taken: int = body.take_damage(damage)
		_spawn_damage_label(damage_taken, body.global_position)


func _update_area_mask(source: Node2D) -> void:
	CollisionMaskFunctions.set_area_collision_mask(_area, source)


func _update_sprite() -> void:
	var texture_size: Vector2 = _sprite.texture.get_size()
	var texture_width: float = texture_size.x
	var new_scale: float = (radius * 2) / texture_width
	_sprite.scale = Vector2(new_scale, new_scale)
	_sprite.flip_h = (randi_range(0, 1) == 1)
	_sprite.flip_v = (randi_range(0, 1) == 1)
	_sprite.modulate = Color(draw_color, 1.0)


func _spawn_damage_label(amount: int, pos: Vector2) -> void:
	var dmg_label: DamageLabel = _DMG_LABEL_SCENE.instantiate()
	get_parent().add_child(dmg_label)
	dmg_label.load_damage(amount, pos)
	dmg_label.play_tween()
