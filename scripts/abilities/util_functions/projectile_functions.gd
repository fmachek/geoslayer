## This class contains some useful functions for working with Projectiles, such as Projectile firing.
class_name ProjectileFunctions

## Instantiates a scene (which should be a Projectile) and sets its ProjectileProperties.
## to the 'properties' parameter, so these properties have to be created beforehand.
## The new projectile is added as a child of the projectile source's parent.
## If the projectile no longer has a source, it is added to the current world.
static func fire_projectile(projectile_scene: PackedScene, properties: ProjectileProperties) -> Projectile:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.set_properties(properties)
	if is_instance_valid(properties.source):
		properties.source.get_parent().add_child(projectile)
	else:
		WorldManager.current_world.add_child(projectile)
	return projectile

## Instantiates a scene (which should be a Projectile). Creates a new ProjectileProperties
## instance and sets its variables, some of them are the function's parameters
## (for example the 'character' parameter is used as the ProjectileProperties 'source' variable). 
static func fire_projectile_from_character(projectile_scene: PackedScene, character: Character, speed: int, damage: int, radius: int) -> Projectile:
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	var direction = (target_pos - player_pos).normalized()
	var draw_color: Color = character.draw_color
	var outline_color: Color = character.outline_color
	var projectile: Projectile = projectile_scene.instantiate()
	
	var properties: ProjectileProperties = ProjectileProperties.new(draw_color, outline_color, direction, speed, character, damage, radius, character.global_position)
	projectile.set_properties(properties)
	properties.source.get_parent().add_child(projectile)
	return projectile
