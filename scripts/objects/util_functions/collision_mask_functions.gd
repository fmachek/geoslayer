class_name CollisionMaskFunctions


## Sets the [Area2D] collision mask based on what type the
## [param source] is. For example, a [PlayerCharacter]'s
## [Projectile] will only be able to collide with walls,
## enemies, and containers.
static func set_area_collision_mask(area: Area2D, source: Node2D) -> void:
	if source:
		if source is PlayerCharacter:
			set_mask_for_layers([1, 8, 11], area)
		elif source is Minion:
			set_mask_for_layers([1, 8, 11], area)
		elif source is Enemy:
			set_mask_for_layers([1, 7, 10], area)
		elif source is Turret:
			set_mask_for_layers([1, 7, 10], area)
	else:
		set_mask_for_layers([1, 7, 10], area)


## Sets the mask of an [param area] to [code]true[/code] for every
## layer in [param layers].
static func set_mask_for_layers(layers: Array[int], area: Area2D) -> void:
	for layer: int in layers:
		area.set_collision_mask_value(layer, true)
