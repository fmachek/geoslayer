class_name FalloffProjectile
extends Projectile

var min_damage: int = 2
var original_pos: Vector2
var final_pos: Vector2
var damage_reduction_multiplier: float = 0.05
var distance_threshold: float = 150.0


func _ready() -> void:
	super()
	original_pos = global_position
	hit_character.connect(_modify_damage.unbind(1))
	if min_damage > projectile_properties.damage:
		min_damage = projectile_properties.damage


func _modify_damage() -> void:
	final_pos = global_position
	var distance: float = original_pos.distance_to(final_pos)
	
	if distance <= distance_threshold:
		return # Deals max damage
	
	var damage_reduction: int = damage_reduction_multiplier * distance
	if projectile_properties.damage - damage_reduction < min_damage:
		projectile_properties.damage = min_damage
	else:
		projectile_properties.damage -= damage_reduction
