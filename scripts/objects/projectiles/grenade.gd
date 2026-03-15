class_name Grenade
extends Projectile

## Represents a grenade which, upon impact, deals damage and spawns more smaller projectiles.
##
## This class uses [member Projectile.explosion_body] to track the Node2D which caused
## the explosion. This variable prevents the smaller projectiles from dealing damage
## to that object.

## The node which caused the explosion (the [Grenade] collided with it).
var explosion_body: Node2D = null
## Scene used to instantiate [GrenadeProjectile].
var proj_scene: PackedScene = load("res://scenes/objects/projectiles/grenade_projectile.tscn")

func _ready() -> void:
	# Smaller projectiles are spawned after exploding
	exploded.connect(spawn_projectiles)

func handle_character_collision(character: Character) -> void:
	can_deal_damage = false
	explosion_body = character
	deal_damage(character)
	explode()

## Spawns multiple [GrenadeProjectile] instances which fly into different directions
## outward from the position where the [Grenade] exploded.
func spawn_projectiles() -> void:
	if explosion_body is not Character: return
	var angle = 0
	while angle < 360:
		var dir_to_angle = Vector2.from_angle(deg_to_rad(angle))
		spawn_projectile(dir_to_angle)
		angle += 45

## Spawns a single [GrenadeProjectile] which flies in a [param direction].
func spawn_projectile(direction: Vector2) -> void:
	var source = null
	if is_instance_valid(projectile_properties.source):
		source = projectile_properties.source
	var damage: int = projectile_properties.damage * 0.75
	var radius: int = projectile_properties.radius * 0.75
	var proj_props := ProjectileProperties.new(projectile_properties.draw_color, projectile_properties.outline_color, direction, projectile_properties.speed, source, damage, radius, global_position)
	var proj: GrenadeProjectile = ProjectileFunctions.fire_projectile(proj_scene, proj_props)
	proj.explosion_body = explosion_body
