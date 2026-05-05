class_name PlayerCharacter
extends Character
## Represents the player's character.
##
## A [PlayerCharacter] can have 2 abilities equipped. They also have perk points
## which they can spend to increase stats.
##
## The movement is controlled by WASD or arrows.

#region signals
## Emitted when the [Ability] equipped in slot 1 changes.
signal ability1_changed(new_ability: Ability)
## Emitted when the [Ability] equipped in slot 2 changes.
signal ability2_changed(new_ability: Ability)
## Emitted when a new [Ability] is unlocked.
signal new_ability_unlocked(ability: Ability)
## Emitted when [member perk_points_available] changes.
signal perk_points_available_changed(new_amount: int)
#endregion

#region variables
## [Ability] equipped in slot 1.
var ability1: Ability = null
## [Ability] equipped in slot 2.
var ability2: Ability = null
## Array of unlocked abilities.
var unlocked_abilities: Array[Ability] = []
## Perk points owned by the player to spend on stat increases.
var perk_points_available: int = 5:
	set(value):
		if value >= 0:
			perk_points_available = value
			perk_points_available_changed.emit(value)
## Amount of perk points the player gains with every level up.
var perk_points_per_level: int = 5
#endregion


func _ready() -> void:
	super()
	load_unlocked_abilities()
	equip_ability(unlocked_abilities[0]) # Equip first unlocked ability on spawn
	target_pos = get_global_mouse_position()
	_apply_user_stats()
	_fill_health()


func _process(delta: float) -> void:
	super._process(delta)
	target_pos = get_global_mouse_position()
	_move_aim_indicator()


# Moves on every physics frame.
func _physics_process(delta) -> void:
	super(delta)
	get_input()
	move_and_slide()


# Input handling from Godot Docs
# (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
# (partially)
func _unhandled_input(event) -> void:
	if is_stunned:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if ability1:
				ability1.cast()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			if ability2:
				ability2.cast()


# Player drops nothing, so this is just an empty function.
func generate_drop_pool() -> void:
	pass


## Adds perk points on every level up.
func _on_level_changed(_new_level: int) -> void:
	add_perk_points(perk_points_per_level)


## Equips an [Ability]. Abilities can be equipped in 2 slots. If slot 1 is already
## equipped, then the [Ability] is equipped in slot 2. If both are already equipped,
## the first slot is replaced.
func equip_ability(ability: Ability) -> void:
	for equipped_ability in abilities.get_children():
		# Ability is already equipped => return
		if equipped_ability.ability_name == ability.ability_name: return
	if ability1 == null:
		ability1 = ability
		super.equip_ability(ability1)
		ability1_changed.emit(ability1)
	elif ability2 == null:
		ability2 = ability
		super.equip_ability(ability2)
		ability2_changed.emit(ability2)
	else:
		replace_ability1(ability)


## Replaces [Ability] in slot 1. If the new [Ability] is already in slot 2,
## the slots swap their abilities.
func replace_ability1(ability: Ability) -> void:
	if not can_unequip_ability(ability1):
		return
	if ability1 and ability2 and ability:
		if ability2.ability_name == ability.ability_name:
			swap_ability_slots()
			return
	elif ability2 and ability:
		if ability2.ability_name == ability.ability_name:
			# Ability is already in slot 2 but nothing is in slot 1
			replace_ability2(null) # unequip slot 2
	if ability1:
		abilities.remove_child(ability1)
	ability1 = ability
	super.equip_ability(ability1)
	ability1_changed.emit(ability1)


## Replaces [Ability] in slot 2. If the new [Ability] is already in slot 1,
## the slots swap their abilities.
func replace_ability2(ability: Ability) -> void:
	if not can_unequip_ability(ability2):
		return
	if ability2 and ability1 and ability:
		if ability1.ability_name == ability.ability_name:
			# Replacing ability2 with an ability that is already in slot 1
			swap_ability_slots()
			return
	elif ability1 and ability:
		if ability1.ability_name == ability.ability_name:
			# Ability is already in slot 1 but nothing is in slot 2
			replace_ability1(null) # unequip slot 1
	if ability2:
		abilities.remove_child(ability2)
	ability2 = ability
	super.equip_ability(ability2)
	ability2_changed.emit(ability2)


## Swaps abilities in the 2 slots.
func swap_ability_slots() -> void:
	if not (can_unequip_ability(ability1) and can_unequip_ability(ability2)):
		return
	var ability1_temp: Ability = ability1
	ability1 = ability2
	ability2 = ability1_temp
	ability1_changed.emit(ability1)
	ability2_changed.emit(ability2)


## Checks if an [param ability] can be unequipped.
## It cannot be unequipped if it's currently casting or on cooldown.
func can_unequip_ability(ability: Ability) -> bool:
	if ability == null:
		return true
	if ability.is_cooldown or ability.is_casting:
		return false
	return true


## Attempts to unlock a new [Ability]. Returns [code]false[/code] if it is already
## unlocked, or [code]true[/code] if the unlock was successful.
func unlock_new_ability(ability: Ability) -> bool:
	# Check if ability is already unlocked
	for unlocked_ability in unlocked_abilities:
		if unlocked_ability.ability_name == ability.ability_name:
			return false
	# Ability isn't unlocked -> unlock now
	unlocked_abilities.append(ability)
	new_ability_unlocked.emit(ability)
	return true


## Adds [Shoot] to [member unlocked_abilities].
func load_unlocked_abilities() -> void:
	if not unlocked_abilities.is_empty():
		unlocked_abilities.clear()
	var starter_ability: Ability = Shoot.new()
	unlocked_abilities.append(starter_ability)


# Input direction from Godot Docs
# (https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
func get_input() -> void:
	if is_stunned:
		return
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity += input_direction * speed.max_value_after_buffs


## Picks up an [XPOrb], increasing [member level.current_xp].
func pick_up_xp_orb(orb: XPOrb) -> void:
	var xp: int = orb.xp_amount
	level.add_xp(xp)


## Adds a given [param amount] to [member perk_points_available].
func add_perk_points(amount: int) -> void:
	if amount <= 0:
		return
	perk_points_available += amount


## Spends 1 perk point if there are perk points to spend.
func spend_perk_point() -> bool:
	if perk_points_available <= 0:
		return false
	perk_points_available -= 1
	return true


## Spends a perk point and increases the given [param stat]'s
## [member CharacterStat.max_value].
func apply_perk_point(stat: CharacterStat) -> bool:
	var has_points: bool = spend_perk_point()
	if has_points:
		stat.apply_perk_point()
		return true
	return false


func _apply_user_stats() -> void:
	var user_stats: Array[UserStat] = UserManager.user_stats
	for user_stat in user_stats:
		var stat_name: String = user_stat.stat_name
		var stat_value: int = user_stat.stat_value
		var char_stats: Array = get_node("CharacterStats").get_children()
		for child in char_stats:
			if child is CharacterStat:
				if child.stat_name == stat_name:
					child.max_value += child.perk_point_increase * stat_value
					break


func _move_aim_indicator() -> void:
	var aim_indicator: AimIndicator = $AimIndicator
	if aim_indicator:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var direction: Vector2 = (mouse_pos - global_position).normalized()
		var radius: int = $CollisionShape2D.shape.radius
		var offset: int = 12
		aim_indicator.global_position = global_position + direction * (radius + offset)
