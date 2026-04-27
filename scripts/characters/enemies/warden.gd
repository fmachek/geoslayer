class_name Warden
extends Enemy
## Represents an enemy who casts [Stunshot] and buffs other nearby
## enemies' health and damage.

## Base damage buff applied to nearby allies.
var base_damage_buff_amount: int = 5
## Base health buff applied to nearby allies.
var base_health_buff_amount: int = 5

@onready var _buff_area: Area2D = $BuffArea
@onready var _sword_particles: CPUParticles2D = $SwordParticles
@onready var _heart_particles: CPUParticles2D = $HeartParticles
@onready var _buff_timer: Timer = $BuffTimer


func _ready() -> void:
	super()
	var shape = _buff_area.get_node("CollisionShape2D").shape
	var emission_radius: float = shape.radius
	_sword_particles.emission_sphere_radius = emission_radius
	_sword_particles.color = draw_color
	_heart_particles.emission_sphere_radius = emission_radius
	_heart_particles.color = draw_color
	_buff_timer.start()


func _draw() -> void:
	super()
	_draw_buff_area()


func _load_abilities() -> void:
	_load_ability(Stunshot.new())


func _draw_buff_area() -> void:
	var buff_area_shape: CircleShape2D = _buff_area.get_node("CollisionShape2D").shape
	var radius: float = buff_area_shape.radius
	var outline_width: float = radius / 32
	var color := Color(draw_color, 0.3)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, color, outline_width, true)


func _buff_nearby_friendly_units() -> void:
	var bodies: Array[Node2D] = _buff_area.get_overlapping_bodies()
	for body in bodies:
		if body is Enemy:
			_buff_friendly_unit(body)
	_emit_buff_particles()


func _buff_friendly_unit(unit: Enemy) -> void:
	var damage_buff_amount: int = base_damage_buff_amount * level.current_level
	var damage_buff := Buff.new(damage_buff_amount, 0) # Never expires
	damage_buff.apply_to_stat(unit.damage)
	
	var health_buff_amount: int = base_health_buff_amount * level.current_level
	var health_buff := Buff.new(health_buff_amount, 0) # Never expires
	health_buff.apply_to_stat(unit.health)


func _emit_buff_particles() -> void:
	_sword_particles.emitting = true
	_heart_particles.emitting = true


func _on_buff_timer_timeout() -> void:
	_buff_nearby_friendly_units()
