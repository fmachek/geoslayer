class_name PlayerCharacter
extends Character

## Represents the player's character.
##
## A [PlayerCharacter] can have 2 abilities equipped. They also have perk points
## which they can spend to increase stats.
##
## The movement is controlled by WASD or arrows.

## [Ability] equipped in slot 1.
var ability1: Ability = null
## [Ability] equipped in slot 2.
var ability2: Ability = null

## Emitted when the [Ability] equipped in slot 1 changes.
signal ability1_changed(new_ability: Ability)
## Emitted when the [Ability] equipped in slot 2 changes.
signal ability2_changed(new_ability: Ability)

## Array of unlocked abilities.
var unlocked_abilities: Array[Ability] = []
## Emitted when a new [Ability] is unlocked.
signal new_ability_unlocked(ability: Ability)

## Perk points owned by the player to spend on stat increases.
var perk_points_available: int = 5
## Emitted when [member PlayerCharacter.perk_points_available] changes.
signal perk_points_available_changed(new_amount: int)

# Player drops nothing, so this is just an empty function.
func generate_drop_pool() -> void:
	pass

func _ready() -> void:
	super()
	load_unlocked_abilities()
	equip_ability(unlocked_abilities[0]) # Equip first unlocked ability on spawn
	target_pos = get_global_mouse_position()

## Adds [Shoot] to [member PlayerCharacter.unlocked_abilities].
func load_unlocked_abilities() -> void:
	var starter_ability: Ability = Shoot.new()
	unlocked_abilities.append(starter_ability)

func _process(delta: float) -> void:
	super._process(delta)
	target_pos = get_global_mouse_position()
	move_aim_indicator()

# Simple movement logic is from Godot Docs (https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
func get_input() -> void:
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed.max_value_after_buffs

## Moves on every physics frame.
func _physics_process(delta) -> void:
	get_input()
	move_and_slide()

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

# Input handling from Godot Docs (https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html)
# (partially)
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if ability1:
				ability1.cast()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			if ability2:
				ability2.cast()

## Picks up an [XPOrb], increasing their [member Level.current_xp].
func pick_up_xp_orb(orb: XPOrb) -> void:
	var xp: int = orb.xp_amount
	level.add_xp(xp)

## Moves the aim indicator so that it aims at the current mouse position.
func move_aim_indicator() -> void:
	var aim_indicator: AimIndicator = $AimIndicator
	if aim_indicator:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var direction: Vector2 = (mouse_pos - global_position).normalized()
		var radius: int = $CollisionShape2D.shape.radius
		var offset: int = 12
		aim_indicator.global_position = global_position + direction * (radius + offset)

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

## Swaps abilities in the 2 slots.
func swap_ability_slots() -> void:
	var ability1_temp: Ability = ability1
	ability1 = ability2
	ability2 = ability1_temp
	ability1_changed.emit(ability1)
	ability2_changed.emit(ability2)

## Adds 5 perk points on every level up.
func _on_level_changed(new_level: int) -> void:
	add_perk_points(5)

## Adds a given [param amount] to [member PlayerCharacter.perk_points_available].
func add_perk_points(amount: int) -> void:
	if amount <= 0:
		return
	perk_points_available += amount
	perk_points_available_changed.emit(perk_points_available)

## Spends 1 perk point if there are perk points to spend.
func spend_perk_point() -> bool:
	if perk_points_available <= 0:
		return false
	perk_points_available -= 1
	perk_points_available_changed.emit(perk_points_available)
	return true

## Spends a perk point and increases the given [param stat]'s [member CharacterStat.max_value].
func apply_perk_point(stat: CharacterStat) -> bool:
	var has_points: bool = spend_perk_point()
	if has_points:
		var stat_increase: int = 5
		stat.change_max_value(stat.max_value + stat_increase)
		return true
	return false
