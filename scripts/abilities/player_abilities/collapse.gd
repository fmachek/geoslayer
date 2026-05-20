class_name Collapse
extends Ability

const _BLACK_HOLE_SCENE := preload(
		"res://scenes/objects/black_holes/black_hole.tscn")
const _SPAWN_EFFECT_SCENE := preload(
	"res://scenes/objects/black_holes/black_hole_spawn_effect.tscn"
)

var black_hole_base_damage: int = 50
var black_hole_radius: float = 50.0
var gravity_area_radius: float = 400.0
var expiration_time: float = 4.0
var black_hole_drag: float = 50.0

var cast_time: float = 2.5
var _cast_timer: Timer
var _black_hole_spawn_position: Vector2


func _init() -> void:
	var ability_cooldown: float = 10.0
	var ability_description: String = "Summons a black hole which attracts\
		 enemies for %d seconds. Then it explodes, dealing damage to enemies\
		 and knocking them back." % expiration_time
	super(ability_cooldown, ability_description)


func _ready() -> void:
	_create_cast_timer()


func _perform_ability() -> void:
	var target_pos: Vector2 = character.target_pos
	var col_point: Vector2 = character.get_raycast_collision(target_pos)
	_black_hole_spawn_position = col_point
	_create_spawn_effect(_black_hole_spawn_position)
	_start_casting()


func _reset_ability() -> void:
	if is_instance_valid(_cast_timer):
		_cast_timer.stop()


func _start_casting() -> void:
	_cast_timer.start()


func _finish_casting() -> void:
	if _black_hole_spawn_position:
		_spawn_black_hole(_black_hole_spawn_position)
	finished_casting.emit()


func _spawn_black_hole(position: Vector2) -> void:
	var black_hole: BlackHole = _BLACK_HOLE_SCENE.instantiate()
	black_hole.caster = character
	black_hole.base_damage = black_hole_base_damage
	black_hole.hole_radius = black_hole_radius
	black_hole.gravity_area_radius = gravity_area_radius
	black_hole.expiration_time = expiration_time
	black_hole.drag = black_hole_drag
	black_hole.global_position = position
	character.get_parent().add_child(black_hole)


func _create_cast_timer() -> void:
	if not is_instance_valid(_cast_timer):
		_cast_timer = Timer.new()
		_cast_timer.wait_time = cast_time
		_cast_timer.one_shot = true
		_cast_timer.timeout.connect(_finish_casting)
		add_child(_cast_timer)


func _create_spawn_effect(position: Vector2) -> void:
	var spawn_effect: BlackHoleSpawnEffect = _SPAWN_EFFECT_SCENE.instantiate()
	spawn_effect.bind_to_casting_ability(self)
	spawn_effect.draw_color = character.draw_color
	spawn_effect.outline_color = character.outline_color
	spawn_effect.cast_time = cast_time
	character.get_parent().add_child(spawn_effect)
	spawn_effect.global_position = position
