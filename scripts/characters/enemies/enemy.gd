# Godot Docs helped me a lot with avoidance and pathfinding.
# For example: https://docs.godotengine.org/en/latest/tutorials/navigation/navigation_using_navigationagents.html

class_name Enemy
extends Character

## Represents an enemy which follows the player around and casts abilities.
##
## This class uses [NavigationAgent2D] with RVO avoidance.

## [Character] being followed by the [Enemy].
var target: Character: set = set_target
## Array of abilities ready to be cast.
var castable_abilities: Array[Ability] = []
## Multiplier used to make [Ability] cooldowns longer than usual.
var ability_cooldown_multiplier: float = 3
## Distance at which the [Enemy] stops following [member Character.target].
var stop_distance: float = 180.0
## [NavigationAgent2D] used for avoidance of other enemies.
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
## [Timer] used to time a casting cooldown.
@onready var cast_cooldown_timer: Timer = $CastCooldownTimer


func _ready() -> void:
	super()
	nav_agent.target_desired_distance = stop_distance
	_load_abilities()


# Handles movement.
func _physics_process(delta: float) -> void:
	if target:
		target_pos = target.global_position
		# Set target position in navigation agent
		nav_agent.target_position = target_pos
		
		# Stop here if the navigation is finished
		if nav_agent.is_navigation_finished():
			return
		
		# Calculate direction from the next path position
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized()
		
		# Set the velocity in the navigation agent so it can calculate
		# the safe velocity
		nav_agent.set_velocity(direction * speed.max_value_after_buffs)


# Detects the player entering the enemy's range.
func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		target = body
		cast_random_ability()


# Detects the player leaving the enemy's range.
func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter:
		target = null


## Loads the [Enemy]'s abilities. Needs to be implemented by each
## class extending [Enemy].
func _load_abilities() -> void:
	pass


## Makes the [param ability] cooldown longer, base damage lower,
## and equips the [param ability].
func _load_ability(ability: Ability) -> void:
	ability.cooldown *= ability_cooldown_multiplier # Nerf ability cooldown
	if "base_damage" in ability: # Nerf ability damage
		ability.base_damage = float(ability.base_damage) * 0.3
	equip_ability(ability)
	_add_ability_to_castable(ability)
	# Connect signals that manage castable
	ability.casted.connect(_remove_ability_from_castable.bind(ability))
	ability.finished_casting.connect(cast_random_ability)
	ability.cooldown_ended.connect(_add_ability_to_castable.bind(ability))


## Adds an [Ability] to [member Enemy.castable_abilities]. Also attempts
## to cast a random [Ability].
func _add_ability_to_castable(ability: Ability) -> void:
	castable_abilities.append(ability)
	cast_random_ability()


## Removes an [Ability] from [member Enemy.castable_abilities].
func _remove_ability_from_castable(ability: Ability) -> void:
	castable_abilities.erase(ability)


## Attempts to cast a random [Ability] from [member Enemy.castable_abilities].
func cast_random_ability() -> void:
	if not target: return # No target to attack
	if not cast_cooldown_timer.is_stopped(): return # Cast is on cooldown
	if castable_abilities.is_empty(): return # No abilities to cast
	
	var random_ability: Ability = castable_abilities.pick_random()
	if random_ability:
		target_pos = target.global_position
		cast_cooldown_timer.start()
		random_ability.cast()


## Sets [member Enemy.target] to [code]null[/code].
func remove_target() -> void:
	target = null


## Sets [member Enemy.target] and connects to the [member Character.tree_exiting] signal.
func set_target(new_target: Character):
	if new_target == null:
		if target:
			if target.tree_exiting.is_connected(remove_target):
				target.tree_exiting.disconnect(remove_target)
		target = new_target
	else:
		target = new_target
		if not target.tree_exiting.is_connected(remove_target):
			target.tree_exiting.connect(remove_target)


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	# Skip if navigation is finished
	if nav_agent.is_navigation_finished():
		return
	# Set the velocity, but only if the safe velocity isn't zero
	if safe_velocity != Vector2.ZERO:
		velocity = safe_velocity
	move_and_slide()


func _on_cast_cooldown_timer_timeout() -> void:
	cast_random_ability()
