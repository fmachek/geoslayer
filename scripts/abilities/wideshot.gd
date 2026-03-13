## Represents the Wideshot ability which fires projectiles in a wide cone. It is most effective
## in close range.
class_name Wideshot
extends Ability

var projectile_scene: PackedScene = preload("res://scenes/objects/projectiles/projectile.tscn")
var projectile_speed: int = 5
var base_damage: int = 10
var projectile_radius: int = 6

## Amount of projectiles fired on cast. It must be an odd number.
var projectile_amount: int = 5
## Angle of the cone spread in radians.
var spread_angle: float = deg_to_rad(40)

func _init() -> void:
	super._init(1, "res://assets/sprites/wideshot.png", "Shoots projectiles in a cone.")
	_check_projectile_amount()

## Fires the projectiles.
func perform_ability() -> void:
	spawn_projectiles(projectile_amount)
	finished_casting.emit()

## Fires a given amount of projectiles in a cone. One is always fired in the center and the remaining
## projectiles are fired with an angle offset.
func spawn_projectiles(amount: int) -> void:
	var center_direction: Vector2 = (character.target_pos - character.global_position).normalized()
	var center_angle: float = center_direction.angle()
	var half: int = int(amount/2) # Rounded half of projectiles
	var half_spread_angle: float = spread_angle/2
	# Fire projectiles in the first cone half
	for i in range(1, half+1):
		var angle = center_angle - i * half_spread_angle/half
		_spawn_projectile_in_angle(angle)
	# Fire projectiles in the second cone half
	for i in range(1, half+1):
		var angle = center_angle + i * half_spread_angle/half
		_spawn_projectile_in_angle(angle)
	# Fire center projectile
	_spawn_projectile_in_angle(center_angle)

## Fires a projectile in a direction derived from a given angle in radians.
func _spawn_projectile_in_angle(angle: float) -> void:
	var direction = Vector2.from_angle(angle)
	var damage: int = float(base_damage) * float(character.damage.max_value_after_buffs) / 100
	var projectile_properties: ProjectileProperties = ProjectileProperties.new(character.draw_color, character.outline_color, direction, projectile_speed, character, damage, projectile_radius, character.global_position)
	ProjectileFunctions.fire_projectile(projectile_scene, projectile_properties)

## Checks if the projectile amount is valid - if it's odd. If not, 1 is subtracted from it
## to make it an even number.
func _check_projectile_amount() -> void:
	if projectile_amount % 2 != 0:
		projectile_amount -= 1
