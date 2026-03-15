class_name Character
extends CharacterBody2D

## Represents a character with stats such as health and damage.

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

## The fill color of the circle representing the [Character].
@export var draw_color: Color = Color.LIME_GREEN
## Color of the outline of the circle representing the [Character].
@export var outline_color: Color = Color.SEA_GREEN
## Health stat node.
@onready var health: Health = $CharacterStats/Health
## Damage stat node. Damage is measured in percentage.
@onready var damage: CharacterStat = $CharacterStats/Damage
## Speed stat node.
@onready var speed: CharacterStat = $CharacterStats/Speed
## Level node.
@onready var level: Level = $CharacterStats/Level
## Value used when scaling health with [member Character.level].
@export var base_health: int = 100
## Value used when scaling damage with [member Character.level].
@export var base_damage: int = 100
## Node containing abilities which the [Character] can cast.
@onready var abilities: Node = $Abilities
## Pool of items which can be dropped on death.
var drop_pool: Array[Drop] = []
## True if the [Character] is currently casting an [Ability].
var is_casting: bool = false
## Position which the [Character] is targeting. In case of a [PlayerCharacter], this will
## usually be the current mouse position. For [Enemy], this will usually be
## the [PlayerCharacter]'s position.
var target_pos: Vector2

## Moves the aim line, which is used to display aiming, on every frame.
func _process(delta: float) -> void:
	move_aim_line()

## Draws the [Character]. It is different depending on the collision shape.
## In case of a [PlayerCharacter] for example, it is going to be a circle.
## But other types of [Character] might require a rectangular shape.
func _draw() -> void:
	if $CollisionShape2D.shape is CircleShape2D:
		var radius = $CollisionShape2D.shape.radius
		draw_circle(Vector2.ZERO, radius, draw_color)
		var outline_width = radius/8
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)
	elif $CollisionShape2D.shape is RectangleShape2D:
		var width = $CollisionShape2D.shape.size.x
		var height = $CollisionShape2D.shape.size.y
		draw_rect(Rect2(-width/2, -height/2, width, height), draw_color)
		draw_rect(Rect2(-width/2, -height/2, width, height), outline_color, false, 4)

func _ready() -> void:
	health_changed.connect(check_for_death)
	level.level_changed.connect(_on_level_changed) # Connect level up signal
	update_stats(level.current_level) # Update stats on spawn
	health.change_current_value(health.max_value_after_buffs) # Spawn with max health
	generate_drop_pool()
	$HealthBar.set_up() # Sets up the health bar which appears below the character
	%AimLine.default_color = Color(outline_color, 0.3)

## Makes the [Character] take damage.
func take_damage(damage: int) -> void:
	health.add_value(-damage)

## Heals the [Character] (its health increases).
func heal(amount: int) -> void:
	health.add_value(amount)

## Emits the 'health_changed' signal. This propagates the signal for simplicity.
func emit_health_change(old_health: int, new_health: int) -> void:
	health_changed.emit(old_health, new_health)

## Emits the 'max_health_changed' signal. This propagates the signal for simplicity.
func emit_max_health_change(old_health: int, new_health: int) -> void:
	max_health_changed.emit(old_health, new_health)

## Checks if the [Character] should die on every health change.
func check_for_death(old_health: int, new_health: int) -> void:
	if new_health == 0:
		die()

## Causes the [Character] to die. Drops items from the drop pool, spawns
## death particles and then frees itself. [member Character.died] is emitted
## at the very start of this function.
func die() -> void:
	died.emit()
	drop_items()
	spawn_death_particles()
	get_parent().remove_child(self)
	queue_free()

## Instantiates [DeathParticles].
func spawn_death_particles() -> void:
	var death_particles_scene = load("res://scenes/particle_effects/death_particles.tscn")
	var death_particles = death_particles_scene.instantiate()
	death_particles.color = draw_color
	get_parent().add_child(death_particles)
	death_particles.global_position = global_position
	death_particles.emitting = true

## Equips a new [Ability]. The [Ability] node is added as a
## child of [member Character.abilities].
func equip_ability(ability: Ability) -> void:
	if ability:
		abilities.add_child(ability)
		ability.name = ability.ability_name
		ability.change_character(self)
		ability.casted.connect(start_casting)
		ability.finished_casting.connect(finish_casting)
		ability.unequipping.connect(_on_ability_unequipping)

## Iterates through [member Character.drop_pool] and generates a random 
## number between 0 and 100 for each [Drop]. If that number is lower than
## or equal to [member Drop.chance], the item is dropped.
func drop_items() -> void:
	for drop in drop_pool:
		var chance = drop.chance
		var random_n = randf_range(0, 100)
		if random_n <= chance:
			drop_item(drop)

## Generates the drop pool. Only XP orbs by default.
func generate_drop_pool() -> void:
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))

## Drops an item. It it spawned within the bounds of the collision shape.
## That depends on the shape which can be a circle or a rectangle.
func drop_item(drop: Drop) -> void:
	var random_x: int
	var random_y: int
	if $CollisionShape2D.shape is CircleShape2D:
		random_x = randi_range(global_position.x-$CollisionShape2D.shape.radius, global_position.x + $CollisionShape2D.shape.radius)
		random_y = randi_range(global_position.y-$CollisionShape2D.shape.radius, global_position.y + $CollisionShape2D.shape.radius)
	elif $CollisionShape2D.shape is RectangleShape2D:
		random_x = randi_range(global_position.x-$CollisionShape2D.shape.size.x, global_position.x + $CollisionShape2D.shape.size.x)
		random_y = randi_range(global_position.y-$CollisionShape2D.shape.size.y, global_position.y + $CollisionShape2D.shape.size.y)
	else: return
	var item = load(drop.item_scene_path).instantiate()
	item.global_position = Vector2(random_x, random_y)
	get_parent().add_child(item)

## Changes [member Character.draw_color] and [member Character.outline_color]
## and queues redraw.
func change_color(draw_color: Color, outline_color: Color) -> void:
	self.draw_color = draw_color
	self.outline_color = outline_color
	draw_color_changed.emit(draw_color)
	outline_color_changed.emit(outline_color)
	queue_redraw()

func start_casting() -> void:
	is_casting = true
	started_casting.emit()

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

## Updates stats to scale with the current [Level].
## [member Character.health] and [member Character.damage] increase by 25% of the base value
## with every level.
func update_stats(current_level: int) -> void:
	var new_health: int = base_health + (current_level - 1) * 25
	health.change_max_value(new_health)
	var new_damage: int = base_damage + (current_level - 1) * 25
	damage.change_max_value(new_damage)

## Moves the aim line so that it aims at [member Character.target_pos].
func move_aim_line() -> void:
	if %AimLine.visible:
		var direction_to_target: Vector2 = (target_pos - global_position).normalized()
		var aim_line_start_point: Vector2
		if %AimIndicator:
			aim_line_start_point = %AimIndicator.position
		else:
			aim_line_start_point = Vector2.ZERO
		var aim_line_end_point: Vector2 = global_position + direction_to_target * 2000
		%AimLine.points = PackedVector2Array([Vector2(aim_line_start_point), to_local(aim_line_end_point)])

func show_aim_line():
	%AimLine.show()

func hide_aim_line():
	%AimLine.hide()
