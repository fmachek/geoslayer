class_name DamagingZone
extends Zone
## Represents a [Zone] which damages [Character]s inside of it.

const _DMG_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/damage_label.tscn")

## Base damage dealt by the [DamagingZone].
var base_damage: int = 7
## Damage dealt by the [DamagingZone] every tick.
var damage_per_tick: int = base_damage
## Time each tick takes in seconds.
var time_per_tick: float: set = _set_time_per_tick

@onready var _damage_tick_timer := $DamageTickTimer
@onready var _area: Area2D = $CharacterDetectionArea


func _ready() -> void:
	super()
	became_inactive.connect(func(): _damage_tick_timer.stop())
	caster_changed.connect(_on_caster_changed)
	_update_tick_timer()
	CollisionMaskFunctions.set_area_collision_mask(_area, caster)
	if is_instance_valid(caster):
		_load_caster_variables(caster)


func _handle_body_entered(body: Node2D) -> void:
	pass


func _handle_body_exited(body: Node2D) -> void:
	pass


## Calculates [member damage_per_tick] based on
## [param new_caster]'s damage and [member base_damage].
func _load_caster_variables(new_caster: Character) -> void:
	damage_per_tick = (float(caster.damage.max_value_after_buffs) / 100) * float(base_damage)


# Checks for overlapping bodies on each tick and deals damage to them.
# Checks for character types to prevent friendly fire.
func _on_damage_tick_timer_timeout() -> void:
	$TickParticles.emitting = true
	var bodies: Array[Node2D] = _char_detection_area.get_overlapping_bodies()
	for body: Node2D in bodies:
		if body is not Character:
			continue
		_deal_damage(body)
		_apply_additional_effects(body)


func _apply_additional_effects(character: Character) -> void:
	pass


# Deals damage to a character and spawns a label.
func _deal_damage(character: Character) -> void:
	var damage_taken: int = character.take_damage(damage_per_tick)
	_spawn_damage_label(damage_taken, character.global_position)


# Spawns a label showing the damage dealt.
func _spawn_damage_label(damage: int, pos: Vector2) -> void:
	var damage_label: DamageLabel = _DMG_LABEL_SCENE.instantiate()
	get_parent().add_child(damage_label)
	damage_label.load_damage(damage, pos)
	damage_label.play_tween()


# Updates the wait time of the tick timer to match time_per_tick.
func _update_tick_timer() -> void:
	if _damage_tick_timer:
		_damage_tick_timer.wait_time = time_per_tick


func _set_time_per_tick(value: float) -> void:
	if value <= 0:
		return
	time_per_tick = value
	_update_tick_timer()


func _on_caster_changed(new_caster: Character) -> void:
	CollisionMaskFunctions.set_area_collision_mask(_area, new_caster)
