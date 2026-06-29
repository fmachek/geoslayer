class_name Healer
extends Enemy
## Represents a healer [Enemy] who casts [Lifesteal] and
## [Heal].


func _ready() -> void:
	super()
	died.connect(cast_large_heal)


func _load_abilities() -> void:
	_load_ability(Heal.new())
	
	# Modified version of Wideshot firing lifesteal projectiles
	var wideshot := Wideshot.new()
	wideshot.proj_scene = preload(
		"res://scenes/objects/projectiles/lifesteal_projectile.tscn"
	)
	wideshot.projectile_amount = 3
	wideshot.projectile_speed = 2.0
	wideshot.projectile_radius = 7.0
	wideshot.projectile_knockback = 100.0
	wideshot.spread_angle = deg_to_rad(60)
	wideshot.base_damage = 10
	_load_ability(wideshot)


func cast_large_heal() -> void:
	var heal := Heal.new()
	heal.radius = 600.0
	heal.base_heal_amount = 200
	heal.cooldown = 10.0
	_load_ability(heal)
	heal.cast()
