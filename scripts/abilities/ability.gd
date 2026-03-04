class_name Ability
extends Node2D

var character: Character
var cooldown: float # Cooldown in seconds
var is_cooldown: bool = false
var cooldown_timer: Timer
@export var ability_name: String = "Ability"
var texture: Texture2D
var description: String = "Placeholder"
var is_casting: bool = false

signal casted()
signal finished_casting() # Every specific ability has to emit this at some point
signal cooldown_started()
signal cooldown_ended()

signal unequipping(ability: Ability)

func _init():
	tree_exiting.connect(alert_unequip)
	finished_casting.connect(_on_finished_casting)

func cast():
	if not is_cooldown and not character.is_casting and not is_casting:
		is_casting = true
		casted.emit()
		is_cooldown = true
		cooldown_timer.start()
		cooldown_started.emit()
		perform_ability()

# This needs to be implemented for each specific ability.
func perform_ability():
	pass

func _on_cooldown_timer_timeout() -> void:
	is_cooldown = false
	cooldown_ended.emit()

func change_character(character: Character):
	self.character = character
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

func alert_unequip():
	unequipping.emit(self)
	reset_base()
	reset_ability()

func _on_finished_casting():
	is_casting = false

# Every ability has to implement this (if necessary).
# Used when unequipping, needs to reset the ability to its default state.
func reset_ability():
	pass

func reset_base():
	is_casting = false
	is_cooldown = false
	if cooldown_timer:
		cooldown_timer.stop()

func get_ability_name() -> String:
	var script: Script = get_script()
	if script:
		var ability_name: String = script.resource_path.get_file().get_basename().capitalize()
		return ability_name
	return "Unknown"
