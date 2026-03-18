class_name Wideshot
extends Ability

## Represents the Wideshot ability which fires projectiles in a wide cone.
## It is most effective in close range.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

## Travel speed of the [Projectile]s fired when cast.
var projectile_speed: int = 5
## Base damage of the [Projectile]s fired when cast.
var base_damage: int = 10
## Radius of the [Projectile]s fired when cast.
var projectile_radius: int = 6

## Amount of [Projectile]s fired on cast. It must be an odd number.
var projectile_amount: int = 5
## Angle of the cone spread in radians.
var spread_angle: float = deg_to_rad(40)


func _init() -> void:
	super._init(1, "res://assets/sprites/wideshot.png", "Shoots projectiles in a cone.")
	projectile_amount = _check_projectile_amount(projectile_amount)


## Fires [Projectile]s in a cone.
func _perform_ability() -> void:
	_spawn_projectiles(projectile_amount)
	finished_casting.emit()


## Fires a given [param amount] of [Projectile]s in a cone.
## One is always fired in the center and the remaining
## [Projectile]s are fired with an angle offset.
func _spawn_projectiles(amount: int) -> void:
	var center_direction: Vector2 = (character.target_pos - character.global_position).normalized()
	var center_angle: float = center_direction.angle()
	var half: int = int(amount/2) # Rounded half of projectiles
	var half_spread_angle: float = spread_angle / 2
	# Fire projectiles in the first cone half
	for i in range(1, half + 1):
		var angle: float = center_angle - i * half_spread_angle / half
		_spawn_projectile_in_angle(angle)
	# Fire projectiles in the second cone half
	for i in range(1, half + 1):
		var angle: float = center_angle + i * half_spread_angle / half
		_spawn_projectile_in_angle(angle)
	# Fire center projectile
	_spawn_projectile_in_angle(center_angle)


## Fires a [Projectile] in a direction derived from a given
## [param angle] in radians.
func _spawn_projectile_in_angle(angle: float) -> void:
	var direction = Vector2.from_angle(angle)
	var char_damage: int = character.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(char_damage) / 100
	var projectile_properties := ProjectileProperties.new(
			character.draw_color, character.outline_color,
			direction, projectile_speed, character, damage,
			projectile_radius, character.global_position)
	ProjectileFunctions.fire_projectile(_PROJ_SCENE, projectile_properties)


## Checks if the projectile [param amount] is valid.
## If it isn't odd, 1 is subtracted from it to make it an even number.
## Returns the modified [param amount].
func _check_projectile_amount(amount: int) -> int:
	if amount % 2 != 0:
		amount -= 1
	return amount
