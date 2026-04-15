class_name XPOrb
extends Node2D

## Represents an XP orb which gives XP to a player on pickup.

const _PARTICLES_SCENE = preload("res://scenes/particle_effects/xp_orb_particles.tscn")

## Fill color of the [XPOrb] shape.
@export var draw_color: Color = Color(1.0, 0.0, 1.0, 1.0)
## Outline color of the [XPOrb] shape.
@export var outline_color: Color = Color(0.732, 0.0, 0.732, 1.0)
## Amount of XP given to the [PlayerCharacter] on pickup.
@export var xp_amount: int = 30

var _is_following_player: bool = false
var _player: PlayerCharacter
var _travel_speed: float = 8.0


func _ready() -> void:
	WorldManager.wave_ended.connect(_travel_to_player)


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
	var radius: int = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: int = radius/8
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
