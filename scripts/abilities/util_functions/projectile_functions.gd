class_name ProjectileFunctions
## This class contains some useful functions for working with the [Projectile]
## class such as [Projectile] firing.


## Instantiates [param projectile_scene] which must be a [Projectile] scene
## and sets its [member Projectile.projectile_properties] to [param properties].
## The new [Projectile] is added as a child of the parent of
## [member Projectile.projectile_properties.source].
## If the projectile no longer has a source, it is added to the current world.[br][br]
## Returns the new [Projectile] fired.
static func fire_projectile(projectile_scene: PackedScene, properties: ProjectileProperties) -> Projectile:
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.set_properties(properties)
	
	if is_instance_valid(properties.source):
		properties.source.get_parent().add_child(projectile)
	else:
		WorldManager.current_world.add_child(projectile)
	
	return projectile


## Instantiates [param projectile_scene] which must be a [Projectile] scene.
## Creates a new [ProjectileProperties] instance and sets its variables,
## some of them are required as the function parameters.
## The new [Projectile] is added as a child of the parent of
## [member Projectile.projectile_properties.source].
## If the projectile no longer has a source, it is added to the current world.[br][br]
## Returns the new [Projectile] fired.
static func fire_projectile_from_character(projectile_scene: PackedScene, character: Character, speed: float, damage: int, radius: int) -> Projectile:
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


## Fires multiple [Projectile]s in a cone with a given [param spread] in radians.
## The [param scene] must be a [Projectile] scene.[br][br]
## Returns an [Array] of the [Projectile]s fired.
static func fire_projectile_cone(scene: PackedScene, amount: int, spread: float, caster: Character, base_damage: int, speed: float, radius: int) -> Array[Projectile]:
	var target_pos: Vector2 = caster.target_pos
	var target_dir: Vector2 = caster.global_position.direction_to(target_pos)
	var target_angle: float = target_dir.angle()
	
	var start_angle: float = target_angle - spread / 2
	var projectiles: Array[Projectile] = []
	for i in range(amount):
		var angle: float = start_angle + i * (spread / (amount - 1))
		var proj := fire_projectile_at_angle(
				scene, angle, caster, base_damage, speed, radius)
		projectiles.append(proj)
	return projectiles


## Fires a [Projectile] at a given [param angle] in radians.
## The [param scene] must be a [Projectile] scene.[br][br]
## Returns the new [Projectile].
static func fire_projectile_at_angle(scene: PackedScene, angle: float, caster: Character, base_damage: int, speed: float, radius: int) -> Projectile:
	var direction = Vector2.from_angle(angle)
	var caster_damage: int = caster.damage.max_value_after_buffs
	var damage: int = float(base_damage) * float(caster_damage) / 100
	var projectile_properties := ProjectileProperties.new(
			caster.draw_color, caster.outline_color,
			direction, speed, caster, damage,
			radius, caster.global_position)
	return ProjectileFunctions.fire_projectile(scene, projectile_properties)
