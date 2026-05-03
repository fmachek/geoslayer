class_name Projectile
extends Node2D
## Represents a projectile which travels in a direction and does something on impact.

## Emitted when the [Projectile] explodes.
signal exploded()
## Emitted when a [Character] gets hit by the [Projectile].
signal hit_character(char: Character)

const _PARTICLES_PATH := "res://scenes/particle_effects/projectile_particles.tscn"
const _PARTICLES_SCENE := preload(_PARTICLES_PATH)

## Contains all important properties the [Projectile] requires,
## such as the damage or radius.
var projectile_properties: ProjectileProperties
## Time until the [Projectile] disappears automatically.
var free_time: float = 5.0: set = _set_free_time
## Amount of knockback applied to [Character]s on impact.
var knockback: float = 0.0
## Says whether the [Projectile] can still explode or not.
var can_explode: bool = true
## Says whether the [Projectile] can still deal damage or not.
var can_deal_damage: bool = true

@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _free_timer: Timer = $FreeTimer


func _ready() -> void:
	if not projectile_properties:
		return
	_load_children()
	change_projectile_radius(projectile_properties.radius)
	_update_free_timer(free_time)
	_update_collision_mask()
	global_position = projectile_properties.start_pos
	_free_timer.start()


# Moves on every physics frame.
func _physics_process(delta: float) -> void:
	if can_explode and projectile_properties:
		var speed: float = projectile_properties.speed
		var dir: Vector2 = projectile_properties.direction
		global_position += speed * dir * delta * 200
		look_at(global_position + dir)


# Draws the shape, in this case a circle.
func _draw() -> void:
	if can_explode:
		_draw_projectile_shape()


## Causes the [Projectile] to explode, emitting particles.
## The [Projectile] is freed when the particles finish emitting.
func explode() -> void:
	if can_explode:
		can_explode = false
		can_deal_damage = false
		queue_redraw() # The projectile needs to disappear
		var explosion_particles: ProjectileParticles = _PARTICLES_SCENE.instantiate()
		explosion_particles.load_from_projectile(self)
		%FlyingParticles.emitting = false
		exploded.emit()


## Causes the [Projectile] to disappear
func disappear() -> void:
	can_deal_damage = false
	if can_explode:
		can_explode = false
		queue_redraw() # The projectile needs to disappear
		%FlyingParticles.emitting = false


## Changes the radius of the [Projectile].
func change_projectile_radius(new_radius: int) -> void:
	projectile_properties.radius = new_radius
	if not _col_shape.shape:
		_col_shape.shape = CircleShape2D.new()
	_col_shape.shape.radius = new_radius
	_update_particle_size(new_radius)


## Sets [member projectile_properties].
func set_properties(properties: ProjectileProperties) -> void:
	projectile_properties = properties


# This can be implemented by each specific projectile.
func _draw_projectile_shape() -> void:
	var radius: float = projectile_properties.radius
	var draw_color := projectile_properties.draw_color
	var outline_color := projectile_properties.outline_color
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: float = radius / 8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


# Handles collisions.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Character and can_deal_damage:
		hit_character.emit(body)
		_apply_knockback(body)
		_handle_character_collision(body)
	else:
		explode()


func _on_free_timer_timeout() -> void:
	disappear()


func _update_particle_size(projectile_radius: float) -> void:
	var particles: CPUParticles2D = %FlyingParticles
	particles.scale_amount_min = projectile_radius / 2
	particles.scale_amount_max = particles.scale_amount_min * 2


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
	can_deal_damage = false
	_deal_damage(character)
	explode()


# Deals damage to a Character.
func _deal_damage(character: Character) -> void:
	var damage: int = projectile_properties.damage
	character.take_damage(damage)


func _apply_knockback(character: Character) -> void:
	if knockback > 0.0:
		character.apply_knockback(knockback * projectile_properties.direction)


func _update_collision_mask() -> void:
	var area: Area2D = $Area2D
	var source: Node2D = projectile_properties.source
	CollisionMaskFunctions.set_area_collision_mask(area, source)


func _update_free_timer(new_time: float) -> void:
	if not is_instance_valid(_free_timer):
		return
	_free_timer.stop()
	_free_timer.wait_time = new_time
	_free_timer.start()


func _set_free_time(value: float) -> void:
	if value <= 0:
		value = 0.1
	free_time = value
	_update_free_timer(free_time)
