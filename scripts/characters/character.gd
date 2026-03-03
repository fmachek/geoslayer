# A character can be an NPC, but also the player (the PlayerCharacter class extends this one).

class_name Character
extends CharacterBody2D

# This signal is emitted when the character's health changes.
signal health_changed(old_health: int, new_health: int)
# This signal is emitted when the character's max health changes (max health AFTER BUFFS).
signal max_health_changed(old_health: int, new_health: int)
signal died()

signal draw_color_changed(color: Color)
signal outline_color_changed(color: Color)

signal started_casting()
signal finished_casting()

@export var draw_color: Color = Color.LIME_GREEN # Fill draw color
@export var outline_color: Color = Color.SEA_GREEN # Outline draw color

@onready var health: Health = $CharacterStats/Health
@onready var speed: CharacterStat = $CharacterStats/Speed
@onready var level: Level = $CharacterStats/Level

@onready var abilities: Node = $Abilities

var drop_pool = [] # Pool of items that can be dropped on death

var is_casting: bool = false
# This variable means that the character is currently casting an ability.
# A character can't cast two abilities at once, so this is used to check that.

var target_pos: Vector2

# Draws the character. It is different depending on the collision shape.
# In case of the player for example, it's going to be a circle.
# But for other characters it might be a rectangle.
func _draw():
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
	generate_drop_pool()
	$HealthBar.set_up() # Sets up the health bar which appears below the character

# Makes the player take damage.
func take_damage(damage: int) -> void:
	health.add_value(-damage)

# Makes the player heal (their health increases).
func heal(amount: int) -> void:
	health.add_value(amount)

# Emits the 'health_changed' signal (it's basically just propagating it for simplicity)
func emit_health_change(old_health: int, new_health: int) -> void:
	health_changed.emit(old_health, new_health)

# Emits the 'max_health_changed' signal (it's basically just propagating it for simplicity)
func emit_max_health_change(old_health: int, new_health: int) -> void:
	max_health_changed.emit(old_health, new_health)

# Checks for death on health change
func check_for_death(old_health: int, new_health: int):
	if new_health == 0:
		die()

# Death function
func die():
	drop_items()
	spawn_death_particles()
	get_parent().remove_child(self)
	died.emit()
	queue_free()

func spawn_death_particles():
	var death_particles_scene = load("res://scenes/particle_effects/death_particles.tscn")
	var death_particles = death_particles_scene.instantiate()
	death_particles.color = draw_color
	get_parent().add_child(death_particles)
	death_particles.global_position = global_position
	death_particles.emitting = true

# Equips a new ability. The ability node is added as a child of the
# Abilities node.
func equip_ability(ability: Ability):
	if ability:
		abilities.add_child(ability)
		ability.name = ability.ability_name
		ability.change_character(self)
		ability.casted.connect(start_casting)
		ability.finished_casting.connect(finish_casting)
		ability.unequipping.connect(_on_ability_unequipping)

# Drops items from the drop pool.
func drop_items():
	for drop in drop_pool:
		var chance = drop.chance
		var random_n = randf_range(0, 100)
		if random_n <= chance:
			drop_item(drop)

# Generates the drop pool, in this case it's just XP orbs.
func generate_drop_pool():
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))

# Drops an item. It it spawned within the bounds of the character's collision shape.
# That depends on the shape - circle or rectangle.
func drop_item(drop: Drop):
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

# Changes the draw color and queues redraw.
func change_color(draw_color: Color, outline_color: Color):
	self.draw_color = draw_color
	self.outline_color = outline_color
	draw_color_changed.emit(draw_color)
	outline_color_changed.emit(outline_color)
	queue_redraw()

func start_casting():
	is_casting = true
	started_casting.emit()

func finish_casting():
	is_casting = false
	finished_casting.emit()

func _on_ability_unequipping(ability: Ability):
	# When an ability is being freed or unequipped and it's still casting,
	# we need to set is_casting back to false, otherwise it would stay as true,
	# preventing the character from casting again.
	
	# If the ability is casting, it should be the only ability casting at the time.
	# So if it's being casted, we should be able to know for sure that we can safely
	# set is_casting to true.
	if ability.is_casting:
		finish_casting()
