class_name ProjectileFunctions

## This class contains some useful functions for working with the [Projectile]
## class such as [Projectile] firing.


## Instantiates [param projectile_scene] which should be a [Projectile] scene
## and sets its [member Projectile.projectile_properties] to [param properties].
## The new [Projectile] is added as a child of the parent of
## [member Projectile.projectile_properties.source].
## If the projectile no longer has a source, it is added to the current world.
static func fire_projectile(projectile_scene: PackedScene, properties: ProjectileProperties) -> Projectile:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.set_properties(properties)
	
	if is_instance_valid(properties.source):
		properties.source.get_parent().add_child(projectile)
	else:
		WorldManager.current_world.add_child(projectile)
	
	return projectile


## Instantiates [param projectile_scene] which should be a [Projectile] scene.
## Creates a new [ProjectileProperties] instance and sets its variables,
## some of them are required as the function parameters.
## The new [Projectile] is added as a child of the parent of
## [member Projectile.projectile_properties.source].
## If the projectile no longer has a source, it is added to the current world.
static func fire_projectile_from_character(projectile_scene: PackedScene, character: Character, speed: int, damage: int, radius: int) -> Projectile:
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	var direction: Vector2 = (target_pos - player_pos).normalized()
	var draw_color := character.draw_color
	var outline_color := character.outline_color
	var projectile: Projectile = projectile_scene.instantiate()
	
	var properties := ProjectileProperties.new(
			draw_color, outline_color,
			direction, speed,
			character, damage,
			radius, character.global_position)
	
	projectile.set_properties(properties)
	
	if is_instance_valid(properties.source):
		properties.source.get_parent().add_child(projectile)
	else:
		WorldManager.current_world.add_child(projectile)
	
	return projectile
