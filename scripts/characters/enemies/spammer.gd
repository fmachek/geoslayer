class_name Spammer
extends Enemy

func load_abilities() -> void:
	load_ability(Flurry.new())
	load_ability(Wideshot.new())
