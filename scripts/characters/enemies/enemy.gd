# Godot Docs helped me a lot with avoidance and pathfinding.
# For example: https://docs.godotengine.org/en/latest/tutorials/navigation/navigation_using_navigationagents.html

class_name Enemy
extends Character

var target: Character

var castable_abilities = [] # Abilities ready to be cast
var ability_cooldown_multiplier: float = 3 # Ability cooldowns are longer for enemies

var stop_distance: float = 180.0 # Distance at which the enemy stops following the player

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	super()
	nav_agent.target_desired_distance = stop_distance
	load_abilities()

# Handles movement
func _physics_process(delta):
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

# Detects the player entering the enemy's range
func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		set_target(body)
		cast_random_ability()

# Detects the player leaving the enemy's range
func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter:
		remove_target()

# Loads the enemy's abilities.
func load_abilities():
	load_ability(Shoot.new())
	load_ability(Flurry.new())

# Loads an ability. The enemy's abilities always have a longer cooldown.
func load_ability(ability: Ability):
	ability.cooldown *= ability_cooldown_multiplier # Nerf ability cooldown
	if "base_damage" in ability: # Nerf ability damage
		ability.base_damage = float(ability.base_damage) * 0.3
	equip_ability(ability)
	add_ability_to_castable(ability)
	# Connect signals that manage castable
	ability.casted.connect(remove_ability_from_castable.bind(ability))
	ability.finished_casting.connect(cast_random_ability)
	ability.cooldown_ended.connect(add_ability_to_castable.bind(ability))

# Adds an ability to the list of castable abilities.
func add_ability_to_castable(ability: Ability):
	castable_abilities.append(ability)
	cast_random_ability()

# Removes an ability from the list of castable abilities.
func remove_ability_from_castable(ability: Ability):
	castable_abilities.erase(ability)

# Casts a random ability.
func cast_random_ability():
	if not target:
		return
	var random_ability: Ability = castable_abilities.pick_random()
	if random_ability:
		target_pos = target.global_position
		random_ability.cast()

# Removes the target, disconnecting the signals.
func remove_target():
	if not target: return
	if target.tree_exiting.is_connected(remove_target):
		target.tree_exiting.disconnect(remove_target)
	target = null

# Sets a new target, connecting signals.
func set_target(new_target: Character):
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
