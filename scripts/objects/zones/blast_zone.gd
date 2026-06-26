class_name BlastZone
extends Zone

var base_damage: int = 20
var caster_damage: int = 100
var final_radius: float = 250.0
var knockback: float = 500.0

var _radius_tween: Tween

var characters_hit: Array[Character] = []

@onready var _area: Area2D = get_node("CharacterDetectionArea")


func _init() -> void:
	is_bound_to_caster = false
	fade_out_time = 0.25


func _ready() -> void:
	super()
	CollisionMaskFunctions.set_area_collision_mask(_area, caster)
	caster_damage = caster.damage.max_value_after_buffs
	outline_color = Color(draw_color, 0.75)
	start_radius_tween()
	queue_redraw()


func _handle_body_entered(body: Node2D) -> void:
	if body is Character:
		if not body in characters_hit:
			characters_hit.append(body)
			var damage: int = float(base_damage) * (float(caster_damage)) / 100
			body.take_damage(damage)
			var direction: Vector2 = (body.global_position - global_position).normalized()
			body.apply_knockback(direction * knockback)


func _handle_body_exited(body: Node2D) -> void:
	pass


func _load_caster_variables(new_caster: Character) -> void:
	pass


func start_radius_tween() -> void:
	if _radius_tween:
		_radius_tween.kill()
	_radius_tween = create_tween()
	_radius_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_radius_tween.set_ease(Tween.EASE_IN_OUT)
	_radius_tween.set_trans(Tween.TRANS_QUAD)
	radius = 0.0
	_radius_tween.tween_property(self, "radius", final_radius, life_time)
