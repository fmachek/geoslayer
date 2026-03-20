@abstract class_name Minion
extends CastingCharacter
## Represents a minion spawned by the [PlayerCharacter].
##
## Minions attack the player's enemies and their health decays over time.

## Percentage of health decay on every
## [member Minion._health_decay_timer] tick.
const _HEALTH_DECAY_PERCENTAGE: int = 20
## Timer used to time health decay.
@onready var _health_decay_timer: Timer = $HealthDecayTimer


## Player who spawned the [Minion].
var spawner: PlayerCharacter:
	set(value):
		spawner = value
		value.draw_color_changed.connect(_update_color)
		value.outline_color_changed.connect(_update_color)
		_update_color()


func _init() -> void:
	ability_damage_multiplier = 1.0
	ability_cooldown_multiplier = 1.0
	cast_cooldown = 0.75


func _ready() -> void:
	super()
	_health_decay_timer.timeout.connect(_decay_health)
	level.current_level = spawner.level.current_level
	update_stats(level.current_level)
	health.current_value = health.max_value_after_buffs
	queue_redraw()


# Finds the closest Enemy or Chest in an array of nodes.
func _get_target_from_bodies(bodies: Array[Node2D]) -> Node2D:
	var smallest_distance: float = 100000.0
	var chosen_target: Node2D = null
	for body: Node2D in bodies:
		if (body is Enemy or body is Chest) and body != target:
			var distance: float = global_position.distance_to(body.global_position)
			if distance < smallest_distance:
				smallest_distance = distance
				chosen_target = body
	return chosen_target


# Detects Enemy or Chest nodes entering the detection area.
func _on_character_detection_area_body_entered(body: Node2D) -> void:
	if body is Enemy or body is Chest:
		if target:
			var distance_to_body: float = global_position.distance_to(body.global_position)
			var distance_to_target: float = global_position.distance_to(target.global_position)
			if distance_to_body < distance_to_target:
				target = body
				cast_random_ability()
		else:
			target = body
			cast_random_ability()


# Detects the target exiting the detection area. Scans
# for a new target.
func _on_character_detection_area_body_exited(body: Node2D) -> void:
	if target == body:
		_scan_for_target()


# Updates the draw and outline color to match the spawner.
func _update_color() -> void:
	if spawner:
		draw_color = spawner.draw_color
		outline_color = spawner.outline_color
		queue_redraw()


# Causes the health to decay by a percentage.
func _decay_health() -> void:
	health.current_value -= health.max_value_after_buffs / _HEALTH_DECAY_PERCENTAGE


# Overridden function, updates stats to match the level.
# Causes the Minions to scale with the spawner's level.
func update_stats(current_level: int) -> void:
	var new_health: int = base_health + (current_level - 1) * 2
	health.max_value = new_health
	var new_damage: int = base_damage + (current_level - 1) * 5
	damage.max_value = new_damage


# Overridden function to ensure that Minions
# drop nothing.
func generate_drop_pool() -> void:
	pass
