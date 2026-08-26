class_name HealingOrb
extends Node2D
## Represents a healing orb which heals the player to full HP on pickup.

signal expired()

## Fill color of the [HealingOrb] shape.
@export var draw_color: Color = Color(0.257, 0.742, 0.0, 1.0)
## Outline color of the [HealingOrb] shape.
@export var outline_color: Color = Color(0.162, 0.499, 0.0, 1.0)

var has_expired: bool = false

var _alpha_tween: Tween


func _ready() -> void:
	var world: World = WorldManager.current_world
	var wave_manager: WaveManager = world.wave_manager
	wave_manager.wave_started.connect(expire)
	expired.connect(_fade_out)


func _draw():
	var radius: float = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: float = radius / 4
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


func expire() -> void:
	if has_expired:
		return
	has_expired = true
	expired.emit()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter and not has_expired:
		body.heal(body.health.max_value_after_buffs)
		queue_free()


func _fade_out() -> void:
	if _alpha_tween:
		_alpha_tween.kill()
	modulate.a = 1.0
	_alpha_tween = create_tween()
	_alpha_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	_alpha_tween.tween_callback(queue_free)
