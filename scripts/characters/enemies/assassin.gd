class_name Assassin
extends Enemy


func _ready() -> void:
	stop_distance = 100.0
	min_cast_cooldown = 0.25
	max_cast_cooldown = 0.25
	super()


func _load_abilities() -> void:
	var rush := Rush.new()
	rush.cooldown = 2.0
	rush.dash_base_damage = 10
	_load_ability(rush)
	
	var swipe := Swipe.new()
	swipe.cooldown = 0.5
	swipe.swipe_damage = 3
	swipe.swipe_length = 150.0
	swipe.cast_range = swipe.swipe_length
	_load_ability(swipe)
