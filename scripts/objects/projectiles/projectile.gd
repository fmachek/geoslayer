class_name Projectile
extends Node2D

var projectile_properties: ProjectileProperties

var can_explode: bool = true
var can_deal_damage: bool = true

var explosion_particles_scene: PackedScene = preload("res://scenes/particle_effects/projectile_particles.tscn")
var damage_label_scene: PackedScene = preload("res://scenes/user_interface/world_labels/damage_label.tscn")
@onready var col_shape: CollisionShape2D = $Area2D/CollisionShape2D

func _process(delta: float) -> void:
	if can_explode and projectile_properties:
		global_position += projectile_properties.speed * projectile_properties.direction * delta * 200
		look_at(global_position + projectile_properties.direction)

# Draws the projectile, in this case a circle.
func _draw() -> void:
	if can_explode:
		draw_projectile_shape()

# This can be implemented by each specific projectile.
func draw_projectile_shape() -> void:
	# Takes the radius of the collision shape (which should be a circle)
	var radius = col_shape.shape.radius
	draw_circle(Vector2.ZERO, projectile_properties.radius, projectile_properties.draw_color)
	var outline_width = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, projectile_properties.outline_color, outline_width, true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not projectile_properties.source or body != projectile_properties.source:
		if body is Character and can_deal_damage:
			if projectile_properties.source:
				if projectile_properties.source is not PlayerCharacter and body is not PlayerCharacter:
					return # Prevents enemies damaging other enemies
			handle_character_collision(body)
		else:
			explode()

func explode():
	if can_explode:
		can_explode = false
		queue_redraw() # The projectile needs to disappear
		var explosion_particles: ProjectileParticles = explosion_particles_scene.instantiate()
		explosion_particles.load_from_projectile(self)
		%FlyingParticles.emitting = false

func disappear():
	if can_explode:
		can_explode = false
		queue_redraw() # The projectile needs to disappear
		%FlyingParticles.emitting = false

func _on_free_timer_timeout() -> void:
	disappear()

func change_projectile_radius(new_radius: int):
	projectile_properties.radius = new_radius
	if not col_shape.shape:
		col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = new_radius
	%FlyingParticles.scale_amount_min = new_radius/2
	%FlyingParticles.scale_amount_max = %FlyingParticles.scale_amount_min*2

func set_properties(properties: ProjectileProperties):
	projectile_properties = properties
	global_position = projectile_properties.start_pos
	
	call_deferred("load_children")
	call_deferred("change_projectile_radius", projectile_properties.radius)
	# need to make sure that the whole projectile has loaded
	# so this is performed later

func load_children() -> void:
	col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = projectile_properties.radius
	%FlyingParticles.color = projectile_properties.draw_color
	%FlyingParticles.direction = -projectile_properties.direction

func _on_flying_particles_finished() -> void:
	queue_free()

# This can be implemented by each specific projectile.
func handle_character_collision(character: Character) -> void:
	can_deal_damage = false
	deal_damage(character)
	explode()

# Deals damage to a character.
func deal_damage(character: Character) -> void:
	var damage: int = projectile_properties.damage
	character.take_damage(damage)
	spawn_damage_label(damage, global_position)

# Spawns a label showing the damage dealt.
func spawn_damage_label(damage: int, pos: Vector2) -> void:
	var damage_label: DamageLabel = damage_label_scene.instantiate()
	get_parent().add_child(damage_label)
	damage_label.load_damage(damage, pos)
	damage_label.play_tween()
