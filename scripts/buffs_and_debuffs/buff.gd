class_name Buff
extends Node
## Represents a buff or debuff which temporarily modifies a [CharacterStat].
##
## It's considered a buff if it's a positive effect and a debuff if it's a negative
## effect. It must be instantiated first and then applied via the
## [method Buff.apply_to_stat] function.[br][br]
## Example of buff application:
## [codeblock]
##var speed_buff: Buff = Buff.new(10, 5) # parameters: amount, seconds
##speed_buff.apply_to_stat(character.speed) # parameter: CharacterStat
## [/codeblock]
##
## If [member duration] is set to 0, the [Buff] won't expire.

## Emitted when the buff/debuff effect takes effect.
## The [Buff] itself is passed as a parameter.
signal began(buff: Buff) # TODO: maybe remove the parameter
## Emitted when the buff/debuff ends. The [Buff] itself
## is passed as a parameter.
signal ended(buff: Buff) # TODO: maybe remove the parameter

## Stat which will be modified temporarily.
var target_stat: CharacterStat
## Amount by which the stat will be modified. Can be positive or negative.
var amount: int
## Says how long the buff/debuff lasts in seconds.
var duration: float
# Timer which times the buff/debuff duration.
var _duration_timer: Timer


## Sets the [param amount] and [param duration]. If [param duration]
## is 0, the buff won't expire.
func _init(amount: int, duration: float) -> void:
	self.amount = amount
	self.duration = duration


## Adds the [Buff] to a given [param stat].
func apply_to_stat(stat: CharacterStat) -> void:
	target_stat = stat
	# Buff will actually start after the added_buff signal is emitted by the stat
	target_stat.added_buff.connect(_on_added_buff)
	ended.connect(target_stat.remove_buff)
	target_stat.add_buff(self)


func _begin() -> void:
	if duration > 0:
		_create_duration_timer()
		_duration_timer.start()
	began.emit(self)


func _on_added_buff(buff: Buff) -> void:
	if buff == self:
		_begin()


func _on_duration_timer_timeout() -> void:
	ended.emit(self)


func _create_duration_timer() -> void:
	_duration_timer = Timer.new()
	add_child(_duration_timer)
	_duration_timer.one_shot = true
	_duration_timer.wait_time = duration
	_duration_timer.timeout.connect(_on_duration_timer_timeout)
