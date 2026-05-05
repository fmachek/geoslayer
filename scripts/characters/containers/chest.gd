class_name Chest
extends Character
## Represents a chest which, upon being destroyed, drops items.
##
## It can drop many XP orbs, temporary buffs and always drops
## a [HealingOrb] which heals the player to maximum health. It also drops
## exactly one random [Ability].
##
## This class uses [member drop_pool] which is inherited from [Character],
## but it also uses a separate [member ability_drop_pool] which ensures
## that every [Chest] drops exactly one [AbilityPickup].

## Array of [Drop] instances with [Ability] scene paths.
static var ability_drop_pool: Array[Drop] = []

## Amount of loops when dropping [XPOrb]s.
var xp_amount: int = 1


## Clears [member ability_drop_pool].
static func clear_ability_pool() -> void:
	ability_drop_pool.clear()


func _ready() -> void:
	super()
	# Ensures that an ability is dropped on death
	died.connect(drop_ability)
	is_immune_to_stun = true
	if ability_drop_pool.is_empty():
		generate_ability_drop_pool()


# Draws a simple chest shape.
func _draw():
	var shape = $CollisionShape2D.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var line_width: float = 4.0
	var rect := Rect2(-width / 2, -height / 2, width, height)
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, line_width)
	draw_line(Vector2(-width / 2, -4), Vector2(width / 2, -4), outline_color, line_width)
	draw_circle(Vector2(0, -4), 6, outline_color, true)


## Generates the drop pool. By default, a [Chest] can drop temporary buffs,
## [XPOrb]s and a [HealingOrb].
func generate_drop_pool():
	drop_pool.append(
			Drop.new("res://scenes/objects/buff_objects/health_buff_object.tscn", 30))
	drop_pool.append(
			Drop.new("res://scenes/objects/buff_objects/speed_buff_object.tscn", 30))
	drop_pool.append(
			Drop.new("res://scenes/objects/buff_objects/damage_buff_object.tscn", 30))
	for i in range(xp_amount):
		drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
		drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/healing_orb.tscn", 100))


## Shows the [Label] displaying information about the [Chest]
## and sets its text.
func show_info_label(text: String) -> void:
	$InfoLabel.text = text
	$InfoLabel.show()


## Uses [member ability_drop_pool] to randomly pick a [Drop] which
## is used to instantiate an [AbilityPickup]. Chests always drop exactly one
## [AbilityPickup].
func drop_ability() -> void:
	if ability_drop_pool.is_empty(): return
	var ability_drop: Drop = ability_drop_pool.pick_random()
	ability_drop_pool.erase(ability_drop)
	drop_item(ability_drop)


## Appends [Drop] instances to [member ability_drop_pool], each containing
## a path to an [Ability] scene. The drop chance does not matter because ultimately
## it will be ignored. The [Drop] will be picked randomly using
## [method Array.pick_random] inside the [member drop_ability] function.
func generate_ability_drop_pool() -> void:
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/blast_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/cannonball_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/doubleshot_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/flurry_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/wideshot_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/pierce_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/explosive_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/lifesteal_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/shred_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/swipe_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/smash_pickup.tscn", 100))
