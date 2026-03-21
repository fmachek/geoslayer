@abstract class_name Zone
extends Node2D
## Represents a zone which does something to [Character]s who enter it.

## Emitted when the [Zone] becomes inactive.
signal became_inactive()

#region regular variables
## Used to draw the fill of the [Zone] shape.
var draw_color: Color
## Used to draw the outline of the [Zone] shape.
var outline_color: Color
## [Character] who created the [Zone].
var caster: Character: set = _set_caster
## Time until the [Zone] becomes inactive and disappears, in seconds.
var life_time: float = 10.0: set = _set_life_time
## Radius of the [Zone] shape.
var radius: int = 200: set = _set_radius

# False when the Zone is disappearing.
var _is_active: bool = true: set = _set_is_active
# Tween used for fading out when disappearing.
var _fade_tween: Tween
#endregion

# Used to time the lifetime.
@onready var _life_time_timer: Timer = $LifeTimeTimer
# Used to detect characters in the zone.
@onready var _char_detection_area: Area2D = $CharacterDetectionArea


#region abstract functions
## Handles character enter detections.
@abstract func _handle_body_entered(body: Node2D) -> void


## Handles character exit detections.
@abstract func _handle_body_exited(body: Node2D) -> void


## Loads some variables based on the [param new_caster].
## This could be determining the damage dealt by the [Zone]
## based on [param new_caster]'s damage for example.
@abstract func _load_caster_variables(new_caster: Character) -> void
#endregion


func _ready() -> void:
	_handle_radius_change()
	_char_detection_area.body_entered.connect(_handle_body_entered)
	_char_detection_area.body_exited.connect(_handle_body_exited)
	_life_time_timer.timeout.connect(_become_inactive)
	_life_time_timer.wait_time = life_time
	_life_time_timer.start()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: int = radius/24
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


# Updates draw colors to match the caster's colors, but they're
# more transparent.
func _load_caster_colors(draw_color: Color, outline_color: Color) -> void:
	var alpha: float = 0.3
	self.draw_color = Color(draw_color, alpha)
	self.outline_color = Color(outline_color, alpha)


# The zone becomes inactive and starts the fade out effect.
func _become_inactive() -> void:
	_is_active = false
	_life_time_timer.stop()
	$RingParticles.emitting = false
	_play_fade_out_tween()


# Plays a fade out effect and after it's done, frees the Zone.
func _play_fade_out_tween() -> void:
	if _fade_tween:
		_fade_tween.kill()
	var tree: SceneTree = get_tree()
	if tree:
		_fade_tween = get_tree().create_tween()
		_fade_tween.tween_property(self, "modulate:a", 0, 1)
		_fade_tween.play()
		_fade_tween.tween_callback(queue_free)


# Updates radius in the particles and collision shape to match the
# radius variable.
func _handle_radius_change() -> void:
	var ring_particles: CPUParticles2D = $RingParticles
	if ring_particles:
		ring_particles.emission_ring_inner_radius = radius - 10
		ring_particles.emission_ring_radius = radius + 10
	if _char_detection_area:
		_char_detection_area.get_node("CollisionShape2D").shape.radius = radius


func _handle_life_time_change() -> void:
	if _life_time_timer:
		_life_time_timer.wait_time = life_time


#region setters
func _set_caster(new_caster: Character) -> void:
	caster = new_caster
	_load_caster_variables(caster)
	_load_caster_colors(caster.draw_color, caster.outline_color)
	caster.tree_exiting.connect(_become_inactive)


func _set_life_time(value: float) -> void:
	if value <= 0:
		return
	life_time = value
	_handle_life_time_change()


func _set_is_active(value: bool) -> void:
	_is_active = value
	if not value:
		became_inactive.emit()


func _set_radius(value: int) -> void:
	if value <= 0:
		return
	radius = value
	_handle_radius_change()
#endregion
