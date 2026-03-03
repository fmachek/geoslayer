class_name PlayerCharacter
extends Character

var ability1: Ability = null
var ability2: Ability = null

signal ability1_changed(new_ability: Ability)
signal ability2_changed(new_ability: Ability)

var unlocked_abilities = [Shoot.new()]
signal new_ability_unlocked(ability: Ability)

# Player drops nothing
func generate_drop_pool():
	pass

func _ready() -> void:
	super()

func _process(delta: float):
	target_pos = get_global_mouse_position()
	move_aim_indicator()
	move_aim_line() # This is hidden right now

# Simple movement logic is from Godot Docs (https://docs.godotengine.org/en/stable/tutorials/2d/2d_movement.html)
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed.max_value_after_buffs

func _physics_process(delta):
	get_input()
	move_and_slide()

# Equips an ability. Abilities can be equipped in 2 slots. If slot 1 is already
# equipped, then the ability is equipped in slot 2. If both are already equipped,
# the first slot is replaced.
func equip_ability(ability: Ability):
	for equipped_ability in abilities.get_children():
		if equipped_ability.ability_name == ability.ability_name:
			return # Ability is already equipped => return
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

# Replaces ability 1. Checks for duplicates - if the new ability is already in slot 2,
# the slots are just swapped.
func replace_ability1(ability: Ability):
	if ability1 and ability2 and ability:
		if ability2.ability_name == ability.ability_name:
			print("Attempted to replace " + str(ability1.ability_name) + " with " + ability.ability_name + ", but it is already in slot 2. Swapping slots.")
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

# Replaces ability 2. Checks for duplicates - if the new ability is already in slot 1,
# the slots are just swapped.
func replace_ability2(ability: Ability):
	if ability2 and ability1 and ability:
		if ability1.ability_name == ability.ability_name:
			# Replacing ability2 with an ability that is already in slot 1
			print("Attempted to replace " + str(ability2.ability_name) + " with " + ability.ability_name + ", but it is already in slot 1. Swapping slots.")
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
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Q:
			if ability1:
				ability1.cast()
		elif event.pressed and event.keycode == KEY_E:
			if ability2:
				ability2.cast()

# The player picks up an XP orb, increasing their level's XP.
func pick_up_xp_orb(orb: XPOrb):
	var xp = orb.xp_amount
	level.add_xp(xp)

# Moves the aim indicator depending on the current mouse position.
func move_aim_indicator():
	var aim_indicator = $AimIndicator
	if aim_indicator:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var direction = (mouse_pos - global_position).normalized()
		aim_indicator.global_position = global_position + direction*($CollisionShape2D.shape.radius + 12)

# Unlocks a new ability and returns false if it already is unlocked, or true
# if the unlock was successful.
func unlock_new_ability(ability: Ability) -> bool:
	# Check if ability is already unlocked
	for unlocked_ability in unlocked_abilities:
		if unlocked_ability.ability_name == ability.ability_name:
			return false
	# Ability isn't unlocked -> unlock now
	unlocked_abilities.append(ability)
	new_ability_unlocked.emit(ability)
	return true

# Swaps the two ability slots.
func swap_ability_slots():
	var ability1_temp = ability1
	ability1 = ability2
	ability2 = ability1_temp
	ability1_changed.emit(ability1)
	ability2_changed.emit(ability2)

# Moves the aim line so that it aims at the mouse position.
func move_aim_line():
	if %AimLine.visible:
		%AimLine.points = PackedVector2Array([Vector2(%AimIndicator.position), Vector2(get_local_mouse_position())])
