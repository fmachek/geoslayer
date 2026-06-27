class_name Burst
extends Ability

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

var projectile_speed: float = 5.0
var base_damage: int = 20
var projectile_radius: int = 12
var projectile_amount: int = 4
var projectile_knockback: float = 200.0


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_cast_time: float = 0.0
	var ability_description := "Fires projectiles in all directions."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	_spawn_projectiles(projectile_amount)
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _spawn_projectiles(amount: int) -> void:
	for i in range(amount):
		# Calculate the angle for this specific projectile
		var angle: float = i * (TAU / amount)
		# Create a direction vector from that angle
		var direction := Vector2.from_angle(angle)
		var char_damage: int = character.damage.max_value_after_buffs
		var damage: int = float(base_damage) * float(char_damage) / 100
		var projectile_properties := ProjectileProperties.new(
				character.draw_color, character.outline_color,
				direction, projectile_speed,
				character, damage, projectile_radius,
				character.global_position)
		var proj := ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
		proj.knockback = projectile_knockback
