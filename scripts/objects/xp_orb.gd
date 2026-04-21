class_name XPOrb
extends Node2D
## Represents an XP orb which gives XP to a player on pickup.

const _PARTICLES_SCENE = preload("res://scenes/particle_effects/xp_orb_particles.tscn")

## Amount of XP given to the [PlayerCharacter] on pickup.
static var xp_amount: int = 30

## Fill color of the [XPOrb] shape.
@export var draw_color: Color = Color(1.0, 0.0, 1.0, 1.0)
## Outline color of the [XPOrb] shape.
@export var outline_color: Color = Color(0.732, 0.0, 0.732, 1.0)
@export var min_radius: float = 6
@export var max_radius: float = 8

var _is_following_player: bool = false
var _player: PlayerCharacter
var _travel_speed: float = 8.0

@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	_col_shape.shape = CircleShape2D.new()
	_randomize_radius()
	_travel_to_player()


func _physics_process(delta: float) -> void:
	if _is_following_player:
		if is_instance_valid(_player):
			var dir: Vector2 = global_position.direction_to(_player.global_position)
			global_position += _travel_speed * dir * delta
			_travel_speed += delta * 200
		else:
			_is_following_player = false
			_player = null


func _draw():
	var radius: float = _col_shape.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: float = radius / 8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		body.pick_up_xp_orb(self)
		var xp_orb_particles: XPOrbParticles = _PARTICLES_SCENE.instantiate()
		xp_orb_particles.load_from_orb(self)
		queue_free()


func _travel_to_player() -> void:
	var player: PlayerCharacter = PlayerManager.current_player
	if is_instance_valid(player):
		_is_following_player = true
		self._player = player


func _randomize_radius() -> void:
	var shape = _col_shape.shape
	shape.radius = randf_range(min_radius, max_radius)
