class_name Blast
extends Ability

## Represents the Blast ability which fires projectiles outward in all directions.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile]s fired when cast.
var projectile_speed: int = 2
## Base damage of the [Projectile]s fired when cast.
var base_damage: int = 10
## Radius of the [Projectile]s fired when cast.
var projectile_radius: int = 12
## Amount of [Projectile]s fired when cast.
var projectile_amount: int = 20


func _init() -> void:
	super._init(2, "Shoots projectiles in all directions.")


## Fires projectiles in all directions outward from the caster.
func _perform_ability() -> void:
	_spawn_projectiles(projectile_amount)
	finished_casting.emit()


## Fires [Projectile]s in all directions outward from the caster.
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
		ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)
