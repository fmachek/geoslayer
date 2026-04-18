class_name Blast
extends Ability
## Represents the Blast ability which fires projectiles outward in all directions.
## Each of the projectiles applies a long knockback.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile]s fired when cast.
var projectile_speed: int = 5
## Base damage of the [Projectile]s fired when cast.
var base_damage: int = 15
## Radius of the [Projectile]s fired when cast.
var projectile_radius: int = 12
## Amount of [Projectile]s fired when cast.
var projectile_amount: int = 20
## Knockback applied to [Character]s hit by the [Projectile]s.
var projectile_knockback: float = 1200.0


func _init() -> void:
	super(2, "Shoots projectiles with long knockback in all directions.")


func _perform_ability() -> void:
	_spawn_projectiles(projectile_amount)
	finished_casting.emit()


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
