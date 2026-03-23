class_name Projectile
extends Node2D

## Represents a projectile which travels in a direction and does something on impact.

## Emitted when the [Projectile] explodes.
signal exploded()

# Path to the ProjectileParticles scene.
const _PARTICLES_PATH := "res://scenes/particle_effects/projectile_particles.tscn"
# Path to the DamageLabel scene.
const _LABEL_PATH := "res://scenes/user_interface/world_labels/damage_label.tscn"

## Contains all important properties the [Projectile] requires,
## such as the damage or radius.
var projectile_properties: ProjectileProperties: set = _set_properties

var _can_explode: bool = true
var _can_deal_damage: bool = true
var _explosion_particles_scene := preload(_PARTICLES_PATH)
var _damage_label_scene := preload(_LABEL_PATH)

@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D


# Moves on every physics frame.
func _physics_process(delta: float) -> void:
	if _can_explode and projectile_properties:
		global_position += projectile_properties.speed * projectile_properties.direction * delta * 200
		look_at(global_position + projectile_properties.direction)


# Draws the shape, in this case a circle.
func _draw() -> void:
	if _can_explode:
		_draw_projectile_shape()


# This can be implemented by each specific projectile.
func _draw_projectile_shape() -> void:
	var radius: int = _col_shape.shape.radius
	draw_circle(Vector2.ZERO, projectile_properties.radius, projectile_properties.draw_color)
	var outline_width: int = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, projectile_properties.outline_color, outline_width, true)


# Handles collisions.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Character and _can_deal_damage:
		_handle_character_collision(body)
	else:
		explode()


## Causes the [Projectile] to explode, emitting particles. The [Projectile] is freed
## when the particles finish.
func explode() -> void:
	if _can_explode:
		_can_explode = false
		queue_redraw() # The projectile needs to disappear
		var explosion_particles: ProjectileParticles = _explosion_particles_scene.instantiate()
		explosion_particles.load_from_projectile(self)
		%FlyingParticles.emitting = false
		exploded.emit()


## Causes the [Projectile] to disappear
func disappear() -> void:
	if _can_explode:
		_can_explode = false
		queue_redraw() # The projectile needs to disappear
		%FlyingParticles.emitting = false


func _on_free_timer_timeout() -> void:
	disappear()


## Changes the radius of the [Projectile].
func change_projectile_radius(new_radius: int) -> void:
	projectile_properties.radius = new_radius
	if not _col_shape.shape:
		_col_shape.shape = CircleShape2D.new()
	_col_shape.shape.radius = new_radius
	_update_particle_size(new_radius)


func _update_particle_size(projectile_radius: int) -> void:
	var particles: CPUParticles2D = %FlyingParticles
	particles.scale_amount_min = projectile_radius / 2
	particles.scale_amount_max = particles.scale_amount_min * 2


## Sets [member Projectile.projectile_properties].
func set_properties(properties: ProjectileProperties) -> void:
	projectile_properties = properties
	global_position = projectile_properties.start_pos
	
	# We need to make sure that the whole projectile has loaded
	# so this is performed later
	call_deferred("_load_children")
	call_deferred("change_projectile_radius", projectile_properties.radius)


func _load_children() -> void:
	_col_shape.shape = CircleShape2D.new()
	_col_shape.shape.radius = projectile_properties.radius
	%FlyingParticles.color = projectile_properties.draw_color
	%FlyingParticles.direction = -projectile_properties.direction


func _on_flying_particles_finished() -> void:
	queue_free()


# This can be implemented by each specific projectile. Handles what
# happens on collision with a Character.
func _handle_character_collision(character: Character) -> void:
	_can_deal_damage = false
	_deal_damage(character)
	explode()


# Deals damage to a Character.
func _deal_damage(character: Character) -> void:
	var damage: int = projectile_properties.damage
	character.take_damage(damage)
	_spawn_damage_label(damage, global_position)


# Spawns a label showing the damage dealt.
func _spawn_damage_label(damage: int, pos: Vector2) -> void:
	var damage_label: DamageLabel = _damage_label_scene.instantiate()
	get_parent().add_child(damage_label)
	damage_label.load_damage(damage, pos)
	damage_label.play_tween()


func _set_properties(props: ProjectileProperties) -> void:
	projectile_properties = props
	var source: Node2D = projectile_properties.source
	_set_area_collision_mask(source)


# Sets the Area2D collision mask based on what type the
# projectile source is. For example, a PlayerCharacter's
# projectile will only be able to collide with enemies and
# containers (and walls).
func _set_area_collision_mask(source: Node2D) -> void:
	var area: Area2D = $Area2D
	if source:
		if source is PlayerCharacter:
			_set_mask_for_layers([1, 8, 11], area)
		elif source is Minion:
			_set_mask_for_layers([1, 8, 11], area)
		elif source is Enemy:
			_set_mask_for_layers([1, 7, 10], area)
		elif source is Turret:
			_set_mask_for_layers([1, 7, 10], area)
	else:
		_set_mask_for_layers([1, 7, 10], area)


func _set_mask_for_layers(layers: Array[int], area: Area2D) -> void:
	for layer: int in layers:
		area.set_collision_mask_value(layer, true)
