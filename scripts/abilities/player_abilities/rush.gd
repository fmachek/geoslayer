class_name Rush
extends Ability

const DASH_PARTICLE_SCENE := preload(
	"res://scenes/particle_effects/dash_particles.tscn"
)

var dash_distance: float = 600.0
var dash_duration: float = 0.4
var dash_base_damage: int = 60
var dash_knockback: float = 1000.0

var damage_area: Area2D
var damage: int

var characters_hit: Array[Character] = []


func _init() -> void:
	var ability_cooldown: float = 2.0
	var ability_cast_time: float = dash_duration
	var ability_description: String = "Dash forward, dealing \
			damage to and knocking back enemies passed through."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	pass


func _handle_casting() -> void:
	characters_hit.clear()
	
	var target_pos: Vector2 = character.target_pos
	var target_direction: Vector2 = (target_pos - character.global_position).normalized()
	var dash: Dash = character.dash(dash_distance, dash_duration, target_direction)
	
	var dash_particles: FreeParticles = DASH_PARTICLE_SCENE.instantiate()
	character.add_child(dash_particles)
	dash_particles.global_position = character.global_position
	dash_particles.color = character.draw_color
	dash_particles.direction = -target_direction
	dash_particles.lifetime = dash_duration
	dash_particles.emitting = true
	
	damage_area = create_damage_area()
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	character.add_child(damage_area)
	
	dash.ended.connect(
		func():
			if is_instance_valid(damage_area):
				damage_area.queue_free()
	)
	dash.ended.connect(
		func():
			if is_instance_valid(dash_particles):
				dash_particles.emitting = false
	)
	dash.ended.connect(finished_casting.emit)
	
	var caster_damage: int = character.damage.max_value_after_buffs
	damage = float(dash_base_damage) * (float(caster_damage) / 100)
	
	damage_area.monitoring = true


func create_damage_area() -> Area2D:
	var area := Area2D.new()
	area.monitorable = false
	area.monitoring = false
	area.set_collision_layer(0)
	area.set_collision_mask(0)
	CollisionMaskFunctions.set_area_collision_mask(area, character)
	var col_shape := CollisionShape2D.new()
	col_shape.shape = CircleShape2D.new()
	col_shape.shape.radius = character.get_node("CollisionShape2D").shape.radius
	area.add_child(col_shape)
	return area


func _reset_ability() -> void:
	if is_instance_valid(damage_area):
		damage_area.queue_free()
	damage_area = null
	characters_hit.clear()


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is Character:
		if not body in characters_hit:
			characters_hit.append(body)
			body.take_damage(damage)
			var dir_to_body: Vector2 = (body.global_position 
					- character.global_position).normalized()
			body.apply_knockback(dir_to_body * dash_knockback)
