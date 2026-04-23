class_name SwipeAttack
extends Node2D
## Represents a melee range swipe attack.
##
## The [SwipeAttack] contains an [Area2D] with a [CollisionShape2D]. This [Area2D]
## detects [Character]s and deals damage to them, based on its collision mask.[br][br]
## Usage example:
## [codeblock]
## const SWIPE_SCENE = load("res://scenes/objects/attacks/swipe_attack.tscn")
## var swipe = SWIPE_SCENE.instantiate()
## swipe.source = character # Ability caster for example
## swipe.draw_color = Color(character.draw_color, 0.5)
## swipe.base_damage = 20
## swipe.width = 200.0
## swipe.swipe_angle = deg_to_rad(120.0)
## character.add_child(swipe)
## var target_angle = target_dir.angle() # target_dir is a Vector2 direction
## swipe.swipe(target_angle, 0.25) # Swipe lasts 0.25 seconds
## [/codeblock]
## When instantiating a [SwipeAttack] and setting its properties, [member source]
## should always be set before [member base_damage] so that [member final_damage]
## can update properly. It should then be added as a child of the [member source].
## The actual swipe only happens after calling [member swipe] and it can only be
## called once. The [SwipeAttack] frees itself after it has finished.

## Emitted when [member width] changes.
signal width_changed(new_width: float)
## Emitted when [member height] changes.
signal height_changed(new_height: float)
## Emitted when [member draw_color] changes.
signal draw_color_changed(new_color: Color)
## Emitted when the swipe finishes (it reaches its destination angle).
signal finished()

#region regular variables
## Source of the [SwipeAttack], for example a [Character] who cast
## an [Ability] which instantiated the [SwipeAttack].
var source: Node2D = null
## Width of the [CollisionShape2D], or effectively the length of the [SwipeAttack].
var width: float = 150.0: set = _set_width
## Height of the [CollisionShape2D].
var height: float = 20.0: set = _set_height
## Base damage dealt by the [SwipeAttack]. When set, automatically updates
## [member final_damage] if a [member source] is set.
var base_damage: int = 20: set = _set_base_damage
## Final damage dealt by the [SwipeAttack] after taking [member source] damage
## into consideration.
var final_damage: int = base_damage
## Draw color of the [SwipeAttack]. When set, automatically updates
## the color of particles emitted, if the [CPUParticles2D] node is ready.
var draw_color: Color = Color(0.5, 0.5, 0.5, 0.5): set = _set_draw_color

## Angle which the [SwipeAttack] covers, in radians.
var swipe_angle: float = deg_to_rad(120)
## Time until the [SwipeAttack] reaches the destination angle.
var swipe_time: float = 1.0
#endregion

# These variables are used when lerping the rotation
var _elapsed: float = 0.0
var _start_angle: float
var _end_angle: float
# This variable is used to allow only one swipe() call
var _is_swiping: bool = false

@onready var _area: Area2D = $Area2D
@onready var _shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _particles: CPUParticles2D = $Particles


func _ready() -> void:
	_shape.shape = RectangleShape2D.new()
	width_changed.connect(_update_shape_width)
	height_changed.connect(_update_shape_height)
	draw_color_changed.connect(_update_particle_color)
	_update_shape_width(width)
	_update_shape_height(height)
	_update_particle_color(draw_color)
	_update_collision_mask()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _start_angle and _end_angle:
		if _elapsed < swipe_time:
			global_rotation = lerp_angle(_start_angle, _end_angle, _elapsed / swipe_time)
			_elapsed += delta
		else:
			finished.emit()
			_remove_particles()
			queue_free()


func _draw() -> void:
	var attack_shape: RectangleShape2D = _shape.shape
	var size_x: float = attack_shape.size.x
	var size_y: float = attack_shape.size.y
	var rect_pos := Vector2(0, - size_y / 2)
	var rect_size := Vector2(size_x, size_y)
	var rect := Rect2(rect_pos, rect_size)
	draw_rect(rect, draw_color)


## Starts the swipe attack with its center being at the
## [param target_angle] in radians and it taking [param swipe_time]
## seconds to reach the destination angle.
func swipe(target_angle: float, swipe_time: float) -> void:
	if _is_swiping:
		return
	_is_swiping = true
	_start_angle = target_angle + swipe_angle / 2
	_end_angle = target_angle - swipe_angle / 2
	self.swipe_time = swipe_time
	global_rotation = _start_angle


func _on_body_entered(body: Node2D) -> void:
	if body is Character:
		body.take_damage(final_damage)


func _remove_particles() -> void:
	_particles.reparent(WorldManager.current_world)
	_particles.emitting = false
	_particles.finished.connect(_particles.queue_free)


#region node updates
func _update_shape_width(new_width: float) -> void:
	if not _shape:
		return
	_shape.shape.size = Vector2(new_width, _shape.shape.size.y)
	_update_shape_position()


func _update_shape_height(new_height: float) -> void:
	if not _shape:
		return
	_shape.shape.size = Vector2(_shape.shape.size.x, new_height)


func _update_shape_position() -> void:
	if not _shape:
		return
	_shape.position = Vector2(_shape.shape.size.x / 2, 0)


func _update_collision_mask() -> void:
	CollisionMaskFunctions.set_area_collision_mask(_area, source)


func _update_particle_color(color: Color) -> void:
	if is_instance_valid(_particles):
		_particles.color = color
#endregion


#region setters
func _set_width(value: float) -> void:
	if value < 0:
		value = 0
	width = value
	width_changed.emit(value)


func _set_height(value: float) -> void:
	if value < 0:
		value = 0
	height = value
	height_changed.emit(value)


func _set_base_damage(value: int) -> void:
	if value < 0:
		value = 0
	base_damage = value
	if source:
		if source is Character:
			var char_damage: int = source.damage.max_value_after_buffs
			final_damage = float(base_damage) * float(char_damage) / 100
			return
	final_damage = value


func _set_draw_color(new_color: Color) -> void:
	draw_color = new_color
	draw_color_changed.emit(new_color)
#endregion
