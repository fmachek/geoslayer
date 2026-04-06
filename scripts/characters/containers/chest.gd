class_name Chest
extends Character

## Represents a chest which, upon being destroyed, drops items.
##
## It can drop many XP orbs, temporary buffs and always drops
## a [HealingOrb] which heals the player to maximum health. It also drops
## exactly one random [Ability].
##
## This class uses [member Chest.drop_pool] which is inherited from [Character],
## but it also uses a separate [member Chest.ability_drop_pool] which ensures
## that every [Chest] drops exactly one [AbilityPickup].

## Array of [Drop] instances with [Ability] scene paths.
static var ability_drop_pool: Array[Drop] = []


func _ready() -> void:
	super()
	# Ensures that an ability is dropped on death
	died.connect(drop_ability)
	if ability_drop_pool.is_empty():
		generate_ability_drop_pool()


# Draws a simple chest shape.
func _draw():
	var width: int = $CollisionShape2D.shape.size.x
	var height: int = $CollisionShape2D.shape.size.y
	var line_width: int = 4
	var rect := Rect2(-width/2, -height/2, width, height)
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, line_width)
	draw_line(Vector2(-width/2, -4), Vector2(width/2, -4), outline_color, line_width)
	draw_circle(Vector2(0, -4), 6, outline_color, true)


## Generates the drop pool. In this case, chests have a chance to drop temporary buffs,
## they always drop [XPOrb], but the amount is random (5 orbs are spawned at minimum,
## maximum is 15). A [HealingOrb] always drops as well.[br][br]
func generate_drop_pool():
	drop_pool.append(
			Drop.new("res://scenes/objects/buff_objects/health_buff_object.tscn", 50))
	drop_pool.append(
			Drop.new("res://scenes/objects/buff_objects/speed_buff_object.tscn", 50))
	for i in range(5):
		drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
		drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
		drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 25))
	drop_pool.append(Drop.new("res://scenes/objects/healing_orb.tscn", 100))


## Shows the [Label] displaying information about the [Chest]
## and sets its text.
func show_info_label(text: String) -> void:
	$InfoLabel.text = text
	$InfoLabel.show()


## Uses [member Chest.ability_drop_pool] to randomly pick a [Drop] which
## will be used to instantiate an [AbilityPickup]. Chests always drop exactly one
## [AbilityPickup].
func drop_ability() -> void:
	if ability_drop_pool.is_empty(): return
	var ability_drop: Drop = ability_drop_pool.pick_random()
	ability_drop_pool.erase(ability_drop)
	drop_item(ability_drop)


## Appends [Drop] instances to [member Chest.ability_drop_pool], each containing
## a path to an [Ability] scene. The drop chance does not matter because ultimately
## it will be ignored. The [Drop] will be picked randomly using
## [member Array.pick_random] inside the [member Chest.drop_ability] function.
func generate_ability_drop_pool() -> void:
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/blast_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/cannonball_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/doubleshot_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/flurry_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/wideshot_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/pierce_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/explosive_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/teleport_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/summon_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/storm_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/lifesteal_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/shred_pickup.tscn", 100))
	ability_drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/swipe_pickup.tscn", 100))
