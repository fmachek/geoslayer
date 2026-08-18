class_name Boss2
extends Boss

@export var attack_tile_manager: AttackTileManager

# Abilities
var luckshot: Luckshot
var randomize: Randomize
var teleport: Teleport
var orbs: Orbs
var fortify: Fortify


func _ready() -> void:
	min_cast_cooldown = 0.5
	max_cast_cooldown = 0.5
	super()
	if not is_instance_valid(attack_tile_manager):
		var world: World = WorldManager.current_world
		var manager = world.get_node("BossAttackTileManager")
		if not manager:
			return
		attack_tile_manager = manager


func generate_drop_pool() -> void:
	var point_drop_path: String = "res://scenes/objects/stat_point_drops/stat_point_drop.tscn"
	for i in range(2):
		drop_pool.append(Drop.new(point_drop_path, 100))
	drop_pool.append(Drop.new(point_drop_path, 50))
	drop_pool.append(Drop.new(point_drop_path, 25))


func _load_abilities() -> void:
	luckshot = Luckshot.new()
	randomize = Randomize.new()
	_load_ability(luckshot)
	_load_ability(randomize)


func _start_phase_1() -> void:
	pass


func _start_phase_2() -> void:
	orbs = Orbs.new()
	_load_ability(orbs)
	teleport = Teleport.new()
	teleport.cooldown = 5.0
	teleport.cast_time = 1.0
	_load_ability(teleport)


func _start_phase_3() -> void:
	luckshot.spread_angle_min = deg_to_rad(360)
	luckshot.spread_angle_max = deg_to_rad(360)
	luckshot.projectile_amount_min = 20
	luckshot.projectile_amount_min = 30
	fortify = Fortify.new()
	fortify.shield_base_durability = 300
	fortify.shield_duration = 20.0
	fortify.cooldown = 30.0
	fortify.shield_radius = 100.0
	_load_ability(fortify)
