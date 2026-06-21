class_name Chest
extends Character
## Represents a chest which, upon being destroyed, drops items.
##
## It can drop many XP orbs, temporary buffs and always drops
## a [HealingOrb] which heals the player to maximum health. It also drops
## one random [AbilityPickup].
##
## This class uses [member drop_pool] which is inherited from [Character],
## but it also uses a separate [member ability_drop_pool] which ensures
## that every [Chest] drops exactly one [AbilityPickup].

## Array of [Drop] instances with [Ability] scene paths.
static var ability_drop_pool: Array[Drop] = []

## Amount of loops when dropping [XPOrb]s.
var xp_amount: int = 1
@onready var _col_shape: CollisionShape2D = get_node("CollisionShape2D")


## Clears [member ability_drop_pool].
static func clear_ability_pool() -> void:
	ability_drop_pool.clear()


func _ready() -> void:
	super()
	# Ensures that an ability is dropped on death
	died.connect(drop_ability)
	is_immune_to_stun = true
	is_immune_to_external_velocity = true
	$InfoLabel.label_settings.font_color = draw_color
	if ability_drop_pool.is_empty():
		generate_ability_drop_pool()


# Draws a simple chest shape.
func _draw():
	var shape = _col_shape.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var line_width: float = 6.0
	var rect := Rect2(-width / 2, -height / 2, width, height)
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, line_width)
	draw_line(Vector2(-width / 2, -4), Vector2(width / 2, -4), outline_color, line_width)
	draw_circle(Vector2(0, -4), 8, outline_color, true)


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
	var ability_names: Array[String] = [
		"blast", "cannonball", "doubleshot", "flurry", "wideshot",
		"pierce", "explosive", "lifesteal", "shred", "swipe",
		"smash", "trap", "flee", "return", "tear", "rush"
	]
	add_abilities_to_drop_pool(ability_names)


func add_abilities_to_drop_pool(ability_names: Array[String]) -> void:
	var scene_path_template := "res://scenes/objects/ability_pickups/%s_pickup.tscn"
	for ability_name in ability_names:
		var scene_path := scene_path_template % ability_name.to_lower()
		var drop := Drop.new(scene_path, 100)
		ability_drop_pool.append(drop)
