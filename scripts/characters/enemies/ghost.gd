class_name Ghost
extends Enemy


func _ready() -> void:
	min_cast_cooldown = 0.25
	max_cast_cooldown = 0.25
	super()


func generate_drop_pool() -> void:
	pass


func _load_abilities() -> void:
	var shoot := Shoot.new()
	shoot.projectile_radius = 10.0
	shoot.projectile_knockback = 0.0
	shoot.projectile_speed = 4.0
	shoot.base_damage = 10
	_load_ability(shoot)
