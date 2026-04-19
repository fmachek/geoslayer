class_name Grenade
extends Projectile
## Represents a grenade which, upon impact, deals damage and spawns more smaller projectiles.
##
## This class uses [member _explosion_body] to track the Node2D which caused
## the explosion. This variable prevents the smaller projectiles from dealing damage
## to that object.

## Amount of smaller projectiles spawned on impact.
var projectile_amount: int = 8
## The [Node2D] which caused the explosion (the [Grenade] collided with it).
var _explosion_body: Node2D = null
# Scene used to instantiate GrenadeProjectile.
var _proj_scene := load("res://scenes/objects/projectiles/grenade_projectile.tscn")


func _ready() -> void:
	super()
	# Smaller projectiles are spawned after exploding
	exploded.connect(_spawn_projectiles)


func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_explosion_body = character
	_deal_damage(character)
	explode()


## Spawns multiple [GrenadeProjectile] instances which travel in different directions
## outward from the position where the [Grenade] exploded.
func _spawn_projectiles() -> void:
	if _explosion_body is not Character:
		return
	for i in range(projectile_amount):
		var angle: float = i * (TAU / projectile_amount)
		var dir_to_angle := Vector2.from_angle(angle)
		_spawn_projectile(dir_to_angle)


## Spawns a single [GrenadeProjectile] which travels in a [param direction].
func _spawn_projectile(direction: Vector2) -> void:
	var source: Node2D = null
	if is_instance_valid(projectile_properties.source):
		source = projectile_properties.source
	var damage: int = projectile_properties.damage * 0.5
	var radius: float = projectile_properties.radius * 0.5
	var proj_props := ProjectileProperties.new(
			projectile_properties.draw_color, projectile_properties.outline_color,
			direction, projectile_properties.speed, source, damage, radius,
			global_position)
	var proj: GrenadeProjectile = ProjectileFunctions.fire_projectile(
			_proj_scene, proj_props)
	proj.set_explosion_body(_explosion_body)
