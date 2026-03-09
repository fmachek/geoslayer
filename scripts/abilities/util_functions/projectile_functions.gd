class_name ProjectileFunctions

static func fire_projectile(projectile_scene: PackedScene, properties: ProjectileProperties):
	var projectile: Projectile = projectile_scene.instantiate()
	projectile.set_properties(properties)
	properties.source.get_parent().add_child(projectile)

static func fire_projectile_from_character(projectile_scene: PackedScene, character: Character, speed: int, damage: int, radius: int):
	var target_pos: Vector2 = character.target_pos
	var player_pos: Vector2 = character.global_position
	var direction = (target_pos - player_pos).normalized()
	var draw_color: Color = character.draw_color
	var outline_color: Color = character.outline_color
	var projectile: Projectile = projectile_scene.instantiate()
	
	var properties: ProjectileProperties = ProjectileProperties.new(draw_color, outline_color, direction, speed, character, damage, radius, character.global_position)
	projectile.set_properties(properties)
	properties.source.get_parent().add_child(projectile)
