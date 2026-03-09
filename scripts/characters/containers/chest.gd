class_name Chest
extends Character

# Draws a simple chest shape.
func _draw():
	var width = $CollisionShape2D.shape.size.x
	var height = $CollisionShape2D.shape.size.y
	var line_width = 4
	draw_rect(Rect2(-width/2, -height/2, width, height), draw_color)
	draw_rect(Rect2(-width/2, -height/2, width, height), outline_color, false, line_width)
	draw_line(Vector2(-width/2, -4), Vector2(width/2, -4), outline_color, line_width)
	draw_circle(Vector2(0, -4), 6, outline_color, true)

# Generates the drop pool for this chest - XP orbs, buffs and an ability.
func generate_drop_pool():
	drop_pool.append(Drop.new("res://scenes/objects/buff_objects/health_buff_object.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/buff_objects/speed_buff_object.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 100))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 50))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 25))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 25))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 25))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 25))
	drop_pool.append(Drop.new("res://scenes/objects/xp_orb.tscn", 25))
	drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/blast_pickup.tscn", 10))
	drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/cannonball_pickup.tscn", 10))
	drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/doubleshot_pickup.tscn", 10))
	drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/flurry_pickup.tscn", 10))
	drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/wideshot_pickup.tscn", 10))
	drop_pool.append(Drop.new("res://scenes/objects/ability_pickups/pierce_pickup.tscn", 10))

func show_info_label(text: String) -> void:
	$InfoLabel.text = text
	$InfoLabel.show()
