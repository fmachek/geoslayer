# Godot Docs helped me a lot with avoidance and pathfinding.
# For example: https://docs.godotengine.org/en/latest/tutorials/navigation/navigation_using_navigationagents.html

@abstract class_name CastingCharacter
extends Character
## Represents a character who follows its target around and casts abilities.
##
## This class uses [NavigationAgent2D] with RVO avoidance.

## Emitted when the [member target] has been reached. That is usually
## when the [NavigationAgent2D] navigation finishes.
signal target_reached()
## Emitted when [member target] changes.
signal target_changed(new_target: Character)

## [Character] being followed by the [CastingCharacter].
var target: Character: set = set_target
## Array of abilities ready to be cast.
var castable_abilities: Array[Ability] = []
## Cooldown used to space out individual [Ability] casts.
var cast_cooldown: float = 2.0
## Minimum cooldown applied after every [Ability] cast, in seconds.
var min_cast_cooldown: float = 1.0
## Distance at which the [CastingCharacter] stops following its [member target].
var stop_distance: float = 180.0

## [NavigationAgent2D] used for avoidance of other casting characters.
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
## [Timer] used to time a casting cooldown.
@onready var cast_cooldown_timer: Timer = $CastCooldownTimer


## Loads the [CastingCharacter]'s abilities.
@abstract func _load_abilities() -> void


## Handles bodies entering the character detection area.
@abstract func _on_character_detection_area_body_entered(body: Node2D) -> void


## Handles bodies exiting the character detection area.
@abstract func _on_character_detection_area_body_exited(body: Node2D) -> void


## Finds a new target in an array of nodes.
@abstract func _get_target_from_bodies(bodies: Array[Node2D]) -> Character


func _ready() -> void:
	super()
	nav_agent.target_desired_distance = stop_distance
	cast_cooldown_timer.wait_time = cast_cooldown
	# Attempt to cast when stun ends
	stun_ended.connect(cast_random_ability)
	target_changed.connect(_reset_nav_agent.unbind(1))
	_load_abilities()


# Handles movement.
func _physics_process(delta: float) -> void:
	super(delta)
	if not is_stunned:
		if is_instance_valid(target):
			target_pos = target.global_position
		elif _knockback != Vector2.ZERO:
			move_and_slide()
			return
		# Set target position in navigation agent
		nav_agent.target_position = target_pos
		
		# Stop here if the navigation is finished
		if nav_agent.is_navigation_finished():
			target_reached.emit()
			if _knockback != Vector2.ZERO:
				move_and_slide()
			return
		
		# Calculate direction from the next path position
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		
		# Set the velocity in the navigation agent so it can calculate
		# the safe velocity
		nav_agent.set_velocity(direction * speed.max_value_after_buffs)
	elif _knockback != Vector2.ZERO:
		move_and_slide()


## Attempts to cast a random [Ability] from [member castable_abilities].
func cast_random_ability() -> void:
	if is_stunned: return # Is stunned - can't cast
	if not target: return # No target to attack
	if not cast_cooldown_timer.is_stopped(): return # Cast is on cooldown
	if castable_abilities.is_empty(): return # No abilities to cast
	
	var random_ability: Ability = castable_abilities.pick_random()
	if random_ability:
		target_pos = target.global_position
		cast_cooldown_timer.wait_time = min_cast_cooldown + randf_range(0, 1.0)
		cast_cooldown_timer.start()
		random_ability.cast()


## Sets [member target].
func set_target(new_target: Character) -> void:
	target = new_target
	target_pos = global_position
	target_changed.emit(new_target)


func _load_ability(ability: Ability) -> void:
	equip_ability(ability)
	_add_ability_to_castable(ability)
	# Connect signals that manage castable
	ability.casted.connect(_remove_ability_from_castable.bind(ability))
	ability.finished_casting.connect(cast_random_ability)
	ability.cooldown_ended.connect(_add_ability_to_castable.bind(ability))


func _add_ability_to_castable(ability: Ability) -> void:
	castable_abilities.append(ability)
	cast_random_ability()


func _remove_ability_from_castable(ability: Ability) -> void:
	castable_abilities.erase(ability)


func _reset_nav_agent() -> void:
	if is_instance_valid(nav_agent):
		nav_agent.target_position = global_position
		nav_agent.set_velocity(Vector2.ZERO)


# Finds a new target in an array of nodes overlapping with
# the detection area.
func _scan_for_target() -> void:
	var char_area: Area2D = %CharacterDetectionArea
	var bodies: Array[Node2D] = char_area.get_overlapping_bodies()
	target = _get_target_from_bodies(bodies)
	if not is_instance_valid(target):
		_reset_nav_agent()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	# Skip if the character is stunned
	if is_stunned:
		return
	# Skip if navigation is finished
	if nav_agent.is_navigation_finished():
		return
	# Set the velocity, but only if the safe velocity isn't zero
	if safe_velocity != Vector2.ZERO:
		velocity += safe_velocity
	move_and_slide()


func _on_cast_cooldown_timer_timeout() -> void:
	cast_random_ability()
