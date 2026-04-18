class_name Grenade
extends Projectile

## Represents a grenade which, upon impact, deals damage and spawns more smaller projectiles.
##
## This class uses [member Projectile.explosion_body] to track the Node2D which caused
## the explosion. This variable prevents the smaller projectiles from dealing damage
## to that object.

# The node which caused the explosion (the [Grenade] collided with it).
var _explosion_body: Node2D = null
# Scene used to instantiate GrenadeProjectile.
var _proj_scene: PackedScene = load("res://scenes/objects/projectiles/grenade_projectile.tscn")


func _ready() -> void:
	# Smaller projectiles are spawned after exploding
	exploded.connect(_spawn_projectiles)


func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_explosion_body = character
	_deal_damage(character)
	explode()


## Spawns multiple [GrenadeProjectile] instances which fly into different directions
## outward from the position where the [Grenade] exploded.
func _spawn_projectiles() -> void:
	if _explosion_body is not Character:
		return
	var angle: float = 0.0
	while angle < 360.0:
		var dir_to_angle := Vector2.from_angle(deg_to_rad(angle))
		_spawn_projectile(dir_to_angle)
		angle += 45.0


## Spawns a single [GrenadeProjectile] which flies in a [param direction].
func _spawn_projectile(direction: Vector2) -> void:
	var source: Node2D = null
	if is_instance_valid(projectile_properties.source):
		source = projectile_properties.source
	var damage: int = projectile_properties.damage * 0.5
	var radius: int = projectile_properties.radius * 0.5
	var proj_props := ProjectileProperties.new(projectile_properties.draw_color, projectile_properties.outline_color, direction, projectile_properties.speed, source, damage, radius, global_position)
	var proj: GrenadeProjectile = ProjectileFunctions.fire_projectile(_proj_scene, proj_props)
	proj.set_explosion_body(_explosion_body)
