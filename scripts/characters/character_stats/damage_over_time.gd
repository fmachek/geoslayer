class_name DamageOverTime
extends Node
## Deals damage continually to a [Character]'s health.
##
## Must be instantiated and then [method apply_to] must be called
## so that the [DamageOverTime] node is added as a child of a
## [Character]'s [Health] node.

## Emitted when [member tick_time] changes.
signal tick_time_changed(new_time: float)

const _LABEL_PATH := "res://scenes/user_interface/world_labels/dot_damage_label.tscn"
const _DMG_LABEL_SCENE := preload(_LABEL_PATH)

## Damage dealt on every tick.
var damage_per_tick: int = 5: set = _set_damage_per_tick
## Time between damage ticks in seconds.
var tick_time: float = 1.0: set = _set_tick_time
## Total amount of ticks until the effect ends.
var tick_amount: int = 5: set = _set_tick_amount

var _tick_timer: Timer
var _ticks_remaining: int
var _target_health: Health
var _target_character: Character


func _init(damage: int, tick_time: float, tick_amount: int) -> void:
	damage_per_tick = damage
	self.tick_time = tick_time
	self.tick_amount = tick_amount


func _ready() -> void:
	_ticks_remaining = tick_amount
	_create_tick_timer()


## Attaches to the [param target]'s [Health] node.
func apply_to(target: Character) -> void:
	_target_character = target
	_target_health = target.health
	_target_health.add_child(self)


func _deal_damage() -> void:
	if _target_health and _ticks_remaining > 0:
		_ticks_remaining -= 1
		var damage_taken: int = _target_character.take_damage(damage_per_tick, true)
		_spawn_damage_label(damage_taken, _target_character.global_position)


func _spawn_damage_label(damage: int, pos: Vector2) -> void:
	var damage_label: DamageLabel = _DMG_LABEL_SCENE.instantiate()
	WorldManager.current_world.add_child(damage_label)
	var offset := Vector2(randi_range(-20, 20), randi_range(-20, 20))
	damage_label.load_damage(damage, pos + offset)
	damage_label.play_tween()


func _create_tick_timer() -> void:
	_tick_timer = Timer.new()
	_tick_timer.wait_time = tick_time
	_tick_timer.autostart = true
	_tick_timer.timeout.connect(_deal_damage)
	add_child(_tick_timer)


#region setters
func _set_damage_per_tick(value: int) -> void:
	if value < 0:
		value = 0
	damage_per_tick = value


func _set_tick_time(value: float) -> void:
	if value < 0.1:
		value = 0.1
	tick_time = value
	tick_time_changed.emit(value)


func _set_tick_amount(value: int) -> void:
	if value < 1:
		value = 1
	tick_amount = value
#endregion
