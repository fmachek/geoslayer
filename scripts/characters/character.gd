class_name Character
extends CharacterBody2D
## Represents a character with stats such as health and damage.
##
## [Character]s have knockback implemented, however they don't move by default.
## This class itself does not call [method move_and_slide].

#region signals
## Emitted when health current value changes.
signal health_changed(old_health: int, new_health: int)
## Emitted when health maximum value after buffs changes.
signal max_health_changed(old_health: int, new_health: int)
## Emitted when the [Character] dies (health reaches 0).
signal died()
## Emitted when the draw color changes.
signal draw_color_changed(color: Color)
## Emitted when the outline color changes.
signal outline_color_changed(color: Color)
## Emitted when the [Character] starts casting an [Ability].
signal started_casting()
## Emitted when the [Character] finishes casting an [Ability].
signal finished_casting()
## Emitted when the [Character] gets stunned.
signal was_stunned()
## Emitted when the [Character]'s stun ends.
signal stun_ended()
#endregion

## Represents a damage type, for example normal damage, or damage dealt
## by a DoT effect, but also healing.
enum DamageType {
	NORMAL,
	DOT,
	HEAL
}

const _DMG_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/damage_label.tscn")

#region @export variables
## The fill color of the circle representing the [Character].
@export var draw_color: Color = Color.LIME_GREEN: set = set_draw_color
## Color of the outline of the circle representing the [Character].
@export var outline_color: Color = Color.SEA_GREEN: set = set_outline_color
## Value used when scaling health with [member level].
@export var base_health: int = 100
## Value used when scaling damage with [member level].
@export var base_damage: int = 100
## Reduces knockback applied via [method apply_knockback].
@export var knockback_resistance: int = 0
#endregion

#region regular variables
## Pool of items which can be dropped on death.
var drop_pool: Array[Drop] = []
## True if the [Character] is currently casting an [Ability].
var is_casting: bool = false
## Position which the [Character] is targeting. In case of a [PlayerCharacter], this will
## usually be the current mouse position. For [Enemy], this will usually be
## the [PlayerCharacter]'s position.
var target_pos: Vector2
## Says if the [Character] is alive or not.
var is_alive: bool = true
## Says if the [Character] is immune to stuns or not.
var is_immune_to_stun: bool = false
## Says if the [Character] is immune to knockback or not.
var is_immune_to_knockback: bool = false
## Says if the [Character] is currently stunned or not.
var is_stunned: bool = false
## Variable used to say what level the [Character] spawns with.
## It is used to allow setting the level before [member level] is ready.
var initial_level: int = 1

# Knockback vector.
var _knockback := Vector2.ZERO
# Array of vectors which add up to the final knockback.
var _knockback_vectors: Array[Vector2] = []
# Array of timers, each representing one stun.
var _stuns: Array[Timer] = []
# Used for fading in when spawning.
var _fade_tween: Tween
#endregion

#region @onready variables
## Health stat node.
@onready var health: Health = $CharacterStats/Health
## Armor stat node. Every 10 armor blocks 1 point of damage.
@onready var armor: CharacterStat = $CharacterStats/Armor
## Damage stat node. Damage is measured in percentage.
@onready var damage: CharacterStat = $CharacterStats/Damage
## Speed stat node.
@onready var speed: CharacterStat = $CharacterStats/Speed
## Level node.
@onready var level: Level = $CharacterStats/Level
## Node containing abilities which the [Character] can cast.
@onready var abilities: Node = $Abilities
#endregion


func _ready() -> void:
	level.current_level = initial_level
	
	health_changed.connect(check_for_death)
	level.level_changed.connect(_on_level_changed) # Connect level up signal
	was_stunned.connect(_begin_stun)
	stun_ended.connect(_end_stun)
	draw_color_changed.connect(queue_redraw)
	outline_color_changed.connect(queue_redraw)
	
	update_stats(level.current_level) # Update stats on spawn
	_fill_health() # Spawn with max health
	generate_drop_pool()
	
	$HealthBar.set_up(self) # Sets up the health bar which appears below the character
	%AimLine.default_color = Color(outline_color, 0.3)
	_fade_in()


# Moves the aim line, which is used to display aiming, on every frame.
func _process(_delta: float) -> void:
	move_aim_line()


func _physics_process(_delta: float) -> void:
	velocity = Vector2.ZERO
	_calculate_knockback()
	velocity += _knockback


# Draws the Character. It is different depending on the collision shape.
# In case of a PlayerCharacter for example, it is going to be a circle.
# But other types of Character might require a rectangular shape.
func _draw() -> void:
	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		var radius: int = shape.radius
		draw_circle(Vector2.ZERO, radius, draw_color)
		var outline_width: int = radius / 8
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)
	elif shape is RectangleShape2D:
		var width: int = shape.size.x
		var height: int = shape.size.y
		var rect := Rect2(-width / 2, -height / 2, width, height)
		var outline_width: int = 4
		draw_rect(rect, draw_color)
		draw_rect(rect, outline_color, false, outline_width)


## Applies a knockback to the [Character] if it isn't immune to it
## ([member is_immune_to_knockback]).
func apply_knockback(knockback: Vector2) -> void:
	if not is_immune_to_knockback:
		var knockback_value: float = knockback.length()
		if knockback_value == 0:
			return
		var reduced_knockback: float = knockback_value - knockback_resistance
		if reduced_knockback < 0:
			return # Knockback resistance is large enough to block the knockback entirely
		else:
			var multiplier: float = reduced_knockback / knockback_value
			knockback *= multiplier
		if knockback != Vector2.ZERO:
			_knockback_vectors.append(knockback)


## Makes the [Character] take damage. Returns the damage taken,
## which can be different depending on the [Character]'s armor.
## The [param type] says which kind of damage the [Character] is taking,
## for example a Damage Over Time (DOT) effect, or just normal.
## [param ignore_armor] can be set to [code]true[/code] if armor
## is to be ignored.
func take_damage(amount: int, type: DamageType = DamageType.NORMAL, ignore_armor: bool = false) -> int:
	var damage_reduction: int
	if ignore_armor:
		damage_reduction = 0
	else:
		var armor_amount: int = armor.max_value_after_buffs
		damage_reduction = armor_amount / 10
	var damage_taken: int = amount - damage_reduction
	if damage_taken < 0:
		damage_taken = 0
	health.add_value(-damage_taken)
	spawn_damage_label(damage_taken, type)
	return damage_taken


## Spawns a damage label which displays an [param amount].
## The [param dmg_type] determines what the label looks like.
func spawn_damage_label(amount: int, dmg_type: DamageType) -> void:
	var offset_x: int = randi_range(-20, 20)
	var offset_y: int = randi_range(-20, 20)
	var label_pos := global_position + Vector2(offset_x, offset_y)
	var label: DamageLabel = _DMG_LABEL_SCENE.instantiate()
	WorldManager.current_world.add_child(label)
	label.load_label(amount, label_pos, dmg_type, self)
	label.play_tween()


## Sets [member draw_color] to [param color].
func set_draw_color(color: Color) -> void:
	draw_color = color
	draw_color_changed.emit(color)


## Sets [member outline_color] to [param color].
func set_outline_color(color: Color) -> void:
	outline_color = color
	outline_color_changed.emit(color)


## Heals the [Character] (its health increases).
func heal(amount: int, show_label: bool = true) -> void:
	health.add_value(amount)
	if show_label:
		spawn_damage_label(amount, DamageType.HEAL)


func _calculate_knockback() -> void:
	_knockback = Vector2.ZERO
	var new_array: Array[Vector2] = []
	for vector in _knockback_vectors:
		_knockback += Vector2(vector.x, vector.y)
		vector *= 0.9
		if vector.length() >= 40:
			new_array.append(vector)
	_knockback_vectors = new_array


## Emits [signal health_changed]. This propagates the signal for simplicity.
func emit_health_change(old_health: int, new_health: int) -> void:
	health_changed.emit(old_health, new_health)


## Emits [signal max_health_changed]. This propagates the signal for simplicity.
func emit_max_health_change(old_health: int, new_health: int) -> void:
	max_health_changed.emit(old_health, new_health)


## Checks if the [Character] should die on every health change.
func check_for_death(_old_health: int, new_health: int) -> void:
	if new_health == 0:
		die()


## Causes the [Character] to die. Drops items from the drop pool, spawns
## death particles and then frees itself. [signal died] is emitted
## at the start of this function.
func die() -> void:
	is_alive = false
	died.emit()
	drop_items()
	_spawn_death_particles()
	get_parent().remove_child(self)
	queue_free()


# Instantiates DeathParticles.
func _spawn_death_particles() -> void:
	var death_particles_scene = load("res://scenes/particle_effects/death_particles.tscn")
	var death_particles = death_particles_scene.instantiate()
	death_particles.color = draw_color
	get_parent().add_child(death_particles)
	death_particles.global_position = global_position
	death_particles.emitting = true


## Equips a new [Ability]. The [Ability] node is added as a
## child of [member abilities].
func equip_ability(ability: Ability) -> void:
	if ability:
		abilities.add_child(ability)
		ability.name = ability.ability_name
		ability.change_character(self)
		ability.casted.connect(start_casting)
		ability.finished_casting.connect(finish_casting)
		ability.unequipping.connect(_on_ability_unequipping)


## Iterates through the [member drop_pool] and generates a random 
## number between 0 and 100 for each [Drop]. If that number is lower than
## or equal to [member Drop.chance], the item is dropped.
func drop_items() -> void:
	for drop in drop_pool:
		var chance: int = drop.chance
		var random_n: float = randf_range(0, 100)
		if random_n <= chance:
			drop_item(drop)


## Generates the drop pool. Only XP orbs by default.
func generate_drop_pool() -> void:
	for i in range(level.current_level):
		drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))


## Drops an item. It is spawned within the bounds of the collision shape.
## Those depend on the shape which can be a circle or a rectangle.
func drop_item(drop: Drop) -> void:
	var shape = $CollisionShape2D.shape
	var random_x: int
	var random_y: int
	if shape is CircleShape2D:
		var radius: int = shape.radius
		random_x = randi_range(
				global_position.x - radius,
				global_position.x + radius)
		random_y = randi_range(
				global_position.y - radius,
				global_position.y + radius)
	elif shape is RectangleShape2D:
		var size_x: int = shape.size.x
		var size_y: int = shape.size.y
		random_x = randi_range(
				global_position.x - size_x,
				global_position.x + size_x)
		random_y = randi_range(
				global_position.y - size_y,
				global_position.y + size_y)
	else:
		return
	var item = load(drop.item_scene_path).instantiate()
	item.global_position = Vector2(random_x, random_y)
	var parent = get_parent()
	if is_instance_valid(parent):
		parent.call_deferred("add_child", item)


## Changes [member draw_color] and [member outline_color].
func change_color(new_draw_color: Color, new_outline_color: Color) -> void:
	self.draw_color = new_draw_color
	self.outline_color = new_outline_color


## Starts casting.
func start_casting() -> void:
	is_casting = true
	started_casting.emit()


## Finishes casting.
func finish_casting() -> void:
	is_casting = false
	finished_casting.emit()


func _on_ability_unequipping(ability: Ability) -> void:
	# When an ability is being freed or unequipped and it's still casting,
	# we need to set is_casting back to false, otherwise it would stay true,
	# preventing the character from casting again.
	
	# If the ability is casting, it should be the only ability casting at the time.
	# So if it's being casted, we should be able to know for sure that we can safely
	# set is_casting to true.
	if ability.is_casting:
		finish_casting()


# Updates stats on level up.
func _on_level_changed(new_level: int) -> void:
	update_stats(new_level)


## Updates health and damage to scale with the current [Level].
func update_stats(current_level: int) -> void:
	var new_health: int = ceil(float(base_health) * pow(1.25, current_level - 1))
	health.max_value = new_health
	var new_damage: int = ceil(float(base_damage) * pow(1.15, current_level - 1))
	damage.max_value = new_damage


func _fill_health() -> void:
	health.current_value = health.max_value_after_buffs


## Moves the aim line so that it aims at the [member target_pos].
func move_aim_line() -> void:
	if %AimLine.visible:
		var direction_to_target: Vector2 = (target_pos - global_position).normalized()
		var start_point: Vector2
		if %AimIndicator:
			start_point = %AimIndicator.position
		else:
			start_point = Vector2.ZERO
		var end_point: Vector2 = global_position + direction_to_target * 2000
		%AimLine.points = PackedVector2Array([Vector2(start_point), to_local(end_point)])


func show_aim_line():
	%AimLine.show()


func hide_aim_line():
	%AimLine.hide()


## Checks for raycast collisions between self
## and [param global_target_pos]. Returns [param global_target_pos]
## if there were no collisions. Otherwise returns the point at which
## the collision occurred.
func get_raycast_collision(global_target_pos: Vector2) -> Vector2:
	var raycast: RayCast2D = $RayCast2D
	raycast.target_position = to_local(global_target_pos)
	raycast.force_raycast_update()
	var col_point: Vector2 = raycast.get_collision_point()
	if raycast.is_colliding():
		return col_point
	else:
		return global_target_pos


#region stun functions
## Applies a [param duration] seconds long stun if the [Character]
## is not immune to stuns.
func stun(duration: float) -> void:
	if is_immune_to_stun:
		return
	if duration < 0.1: # Minimum stun length is 0.1 seconds
		duration = 0.1
	var stun_timer: Timer = Timer.new()
	stun_timer.name = "StunTimer"
	stun_timer.autostart = true
	stun_timer.wait_time = duration
	stun_timer.timeout.connect(func(): _remove_stun(stun_timer))
	_stuns.append(stun_timer)
	add_child(stun_timer)
	was_stunned.emit()


func _remove_stun(timer: Timer) -> void:
	if timer in _stuns:
		_stuns.erase(timer)
		timer.queue_free()
		_check_stun_status()


func _check_stun_status():
	if _stuns.is_empty():
		stun_ended.emit()


func _begin_stun() -> void:
	is_stunned = true
	_start_stun_particles()


func _end_stun() -> void:
	is_stunned = false
	_stop_stun_particles()


func _start_stun_particles() -> void:
	%StunParticles.emitting = true


func _stop_stun_particles() -> void:
	%StunParticles.emitting = false
#endregion


func _fade_in() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	var fade_time: float = 0.5
	self_modulate.a = 0.0
	_fade_tween.tween_property(self, "self_modulate:a", 1.0, fade_time)
