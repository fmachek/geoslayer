@abstract class_name Ability
extends Node
## Represents an ability which makes a [Character] do something, for example
## fire a projectile. All specific abilities such as [Shoot] extend this class.
##
## Each [Ability] has to implement the [method _perform_ability] and
## [method _handle_casting] methods. Generally, [method _perform_ability]
## is for performing the main action, for example firing a projectile.
## [method _handle_casting] is usually for things like creating visual effects.[br][br]
##
## However, in some cases, [method _handle_casting] itself can be the method
## which performs the main action. For example, in the [Flurry] ability, the
## casting itself is part of the main action, because a flurry of projectiles is
## fired. Therefore, [method _handle_casting] starts its fire timer and
## [method _perform_ability] does nothing. What matters here is the sequence in which
## these methods are called. [method _handle_casting] is called when casting begins,
## [method _perform_ability] is called when casting finishes.[br][br]
##
## Some abilities may also override the [method _reset_ability] method.
## For example, [Flurry] resets its fire timer and resets the amount of projectiles
## remaining.[br][br]
##
## Every [Ability] must have a [member cast_time]. If the cast is instant,
## it should be set to 0. If the casting is part of the main action such as in [Flurry]
## (meaning the whole action is essentially a cast),
## [member cast_time] should be equal to the total time the main action takes. Usually
## that would be the sum of all the time which passes until [signal finished_casting]
## is fired.[br][br]
##
## Every specific [Ability] has to emit [signal finished_casting], but when or where
## exactly that happens can vary.

#region signals
## Emitted when cast.
signal casted() # TODO: rename this signal, maybe
## Emitted when the [Ability] finishes casting. Every specific [Ability] has to
## emit this at some point, but when or where exactly that happens can vary.
## It should, however, always be emitted when [member cast_time] passes.
signal finished_casting()
## Emitted when the cast cooldown starts.
signal cooldown_started()
## Emitted when the cast cooldown ends.
signal cooldown_ended()
## Emitted when being unequipped.
signal unequipping(ability: Ability)
## Emitted when interrupted.
signal was_interrupted()
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
## Amount of time the [Ability] takes to cast in seconds.
var cast_time: float
## Used by NPCs to determine whether casting the [Ability] would
## make sense (for example close range abilities).
var cast_range: float
## The [Character] the [Ability] belongs to.
var character: Character
## [code]true[/code] if the [Ability] is on cooldown.
var is_cooldown: bool = false
## Timer used to time the cast cooldown.
var cooldown_timer: Timer
## Says if the [Ability] is currently being cast.
var is_casting: bool = false
var _cast_timer: Timer
#endregion


## Performs the main ability action.
@abstract func _perform_ability() -> void


## Handles the start of casting. In some cases, it can
## perform the main ability action.
@abstract func _handle_casting() -> void


func _init(cd: float, cast_duration: float, desc: String, range: float = 0) -> void:
	ability_name = get_ability_name()
	self.cooldown = cd
	self.cast_time = cast_duration
	self.cast_range = range
	var texture_path = TextureManager.get_ability_icon_path(get_ability_name())
	self.texture = load(texture_path)
	self.description = desc
	tree_exiting.connect(_alert_unequip)
	finished_casting.connect(_on_finished_casting)


func _ready() -> void:
	if not _cast_timer:
		if cast_time > 0:
			_create_cast_timer()
	if not cooldown_timer:
		_create_cooldown_timer()


func cast() -> void:
	if not is_cooldown and not character.is_casting and not is_casting:
		is_casting = true
		is_cooldown = true
		casted.emit()
		cooldown_timer.start()
		cooldown_started.emit()
		_connect_interrupt()
		_handle_casting()
		if is_instance_valid(_cast_timer):
			_cast_timer.start()
		else:
			_perform_ability()


func interrupt() -> void:
	was_interrupted.emit()
	finished_casting.emit()
	if is_instance_valid(_cast_timer):
		_cast_timer.stop()
	_reset_ability()


## Returns the [Ability] name as a [String]. The name is derived from the script name.
## For example, if the script name is "flurry.gd", the function will return "Flurry".
func get_ability_name() -> String:
	var script: Script = get_script()
	if script:
		var script_path: String = script.resource_path.get_file()
		var script_name: String = script_path.get_basename().capitalize()
		return script_name
	return "Unknown"


func change_character(new_character: Character) -> void:
	self.character = new_character


func _alert_unequip() -> void:
	unequipping.emit(self)
	_reset_base()
	_reset_ability()


func _reset_ability() -> void:
	pass


func _connect_interrupt() -> void:
	character.was_stunned.connect(interrupt)
	unequipping.connect(_disconnect_interrupt.unbind(1))
	finished_casting.connect(_disconnect_interrupt)


func _disconnect_interrupt() -> void:
	character.was_stunned.disconnect(interrupt)
	unequipping.disconnect(_disconnect_interrupt.unbind(1))
	finished_casting.disconnect(_disconnect_interrupt)


func _reset_base() -> void:
	is_casting = false
	is_cooldown = false
	if cooldown_timer:
		cooldown_timer.stop()
	if _cast_timer:
		_cast_timer.stop()


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


func _create_cast_timer() -> void:
	_cast_timer = Timer.new()
	_cast_timer.wait_time = cast_time
	_cast_timer.one_shot = true
	_cast_timer.timeout.connect(_perform_ability)
	add_child(_cast_timer)
