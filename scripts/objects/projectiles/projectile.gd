class_name Projectile
extends Node2D

var draw_color: Color = Color(0.795, 0.423, 0.0, 1.0)
var outline_color: Color = Color(0.619, 0.324, 0.0, 1.0)
var direction: Vector2 = Vector2.ZERO
var speed: int = 8
var source: Node2D
var damage: int = 20
var projectile_radius: int = 10

var can_explode = true

var explosion_particles_scene = preload("res://scenes/particle_effects/projectile_particles.tscn")

@onready var col_shape := $Area2D/CollisionShape2D

func _ready() -> void:
	col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = projectile_radius
	%FlyingParticles.color = draw_color
	%FlyingParticles.direction = -direction

func _process(delta: float) -> void:
	if can_explode:
		global_position += speed * direction * delta * 200

# Draws the projectile, in this case a circle.
func _draw():
	if can_explode:
		# Takes the radius of the collision shape (which should be a circle)
		var radius = col_shape.shape.radius
		draw_circle(Vector2.ZERO, radius, draw_color)
		var outline_width = radius/8
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not source or body != source:
		if body is Character:
			if source:
				if source is Character and source is not PlayerCharacter and body is not PlayerCharacter:
					return # Prevents enemies damaging other enemies
			body.take_damage(damage)
			var damage_label: DamageLabel = load("res://scenes/user_interface/world_labels/damage_label.tscn").instantiate()
			get_parent().add_child(damage_label)
			damage_label.load_damage(damage, global_position)
			damage_label.play_tween()
			explode()
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
	projectile_radius = new_radius
	if not col_shape.shape:
		col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = new_radius
	%FlyingParticles.scale_amount_min = projectile_radius/2
	%FlyingParticles.scale_amount_max = %FlyingParticles.scale_amount_min*2

func set_properties(draw_color: Color, outline_color: Color, direction: Vector2, speed: int, source: Node2D, damage: int, radius: int, start_pos: Vector2):
	self.draw_color = draw_color
	self.outline_color = outline_color
	self.direction = direction
	self.speed = speed
	self.source = source
	self.damage = damage
	global_position = start_pos
	
	call_deferred("change_projectile_radius", radius)
	# need to make sure that the whole projectile has loaded
	# so this is performed later

func _on_flying_particles_finished() -> void:
	queue_free()
