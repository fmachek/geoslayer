@abstract class_name Ability
extends Node
## Represents an ability which makes a character do something, for example
## fire a projectile. All specific abilities such as [Shoot] and [Wideshot]
## extend this class.

#region signals
## Emitted when cast by the [Character].
signal casted() # TODO: rename this signal
## Emitted when the [Ability] finishes casting. Every specific [Ability] has to
## emit this at some point, but when exactly that happens can vary.
signal finished_casting()
## Emitted when the cast cooldown starts.
signal cooldown_started()
## Emitted when the cast cooldown ends.
signal cooldown_ended()
## Emitted when the [Ability] is being unequipped by the [Character].
signal unequipping(ability: Ability)
#endregion

#region variables
## [Ability] name which should be the same as the script name.
var ability_name: String
## String describing what the [Ability] does.
var description: String
## Icon displayed for example in the bottom HUD in the in-game UI.
var texture: Texture2D
## Cooldown in seconds.
var cooldown: float
## The [Character] the [Ability] belongs to.
var character: Character
## [code]true[/code] if the [Ability] is on cooldown.
var is_cooldown: bool = false
## Timer used to time the cast cooldown.
var cooldown_timer: Timer
## Says if the [Ability] is currently being cast.
var is_casting: bool = false
#endregion


## Performs what the [Ability] is supposed to do. This function must be
## implemented by each specific Ability.
@abstract func _perform_ability() -> void


func _init(cooldown: float, description: String) -> void:
	ability_name = get_ability_name()
	self.cooldown = cooldown
	var texture_path = TextureManager.get_ability_icon_path(get_ability_name())
	self.texture = load(texture_path)
	self.description = description
	tree_exiting.connect(_alert_unequip)
	finished_casting.connect(_on_finished_casting)


## Checks if the [Ability] is not on cooldown, if the [Character] can cast
## and if the [Ability] is not already being cast. The cooldown timer
## then starts and the [Ability] is performed.
func cast() -> void:
	if not is_cooldown and not character.is_casting and not is_casting:
		is_casting = true
		is_cooldown = true
		casted.emit()
		cooldown_timer.start()
		cooldown_started.emit()
		_perform_ability()


## Returns the [Ability] name as a [String]. The name is derived from the script name.
## For example, if the script name is "flurry.gd", the function will return "Flurry".
func get_ability_name() -> String:
	var script: Script = get_script()
	if script:
		var script_path: String = script.resource_path.get_file()
		var ability_name: String = script_path.get_basename().capitalize()
		return ability_name
	return "Unknown"


## Changes [member character]. Also creates the cooldown timer.
func change_character(character: Character) -> void:
	self.character = character
	_create_cooldown_timer()


# Emits the unequipping signal and resets itself.
func _alert_unequip() -> void:
	unequipping.emit(self)
	_reset_base()
	_reset_ability()


## Every [Ability] can override this function if necessary.
## Used when unequipping, needs to reset the [Ability] to its default state.
## For example, [Flurry] needs to set its amount of projectiles remaining back to
## the default amount if it is unequipped mid-cast.
func _reset_ability() -> void:
	pass


func _reset_base() -> void:
	is_casting = false
	is_cooldown = false
	if cooldown_timer:
		cooldown_timer.stop()


func _on_finished_casting() -> void:
	is_casting = false


func _on_cooldown_timer_timeout() -> void:
	is_cooldown = false
	cooldown_ended.emit()


func _create_cooldown_timer() -> void:
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
