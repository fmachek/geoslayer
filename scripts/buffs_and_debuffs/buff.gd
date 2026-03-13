class_name Buff
extends Node
## A buff or debuff which temporarily changes a CharacterStat.
##
## It's considered a buff if it's
## a positive effect and a debuff if it's a negative effect. It must be instantiated first
## and then applied via the [method Buff.apply_to_stat] function.[br][br]
## Example of buff application:
## [codeblock]
##var speed_buff: Buff = Buff.new(10, 5) # parameters: amount, seconds
##speed_buff.apply_to_stat(character.speed) # parameter: CharacterStat
## [/codeblock]

## Stat which will be modified temporarily.
var target_stat: CharacterStat
## Amount by which the stat will be modified. Can be positive or negative.
var amount: int
## Says how long the buff/debuff lasts in seconds.
var duration: float
## Timer which times the buff/debuff duration.
var duration_timer: Timer

## Emitted when the buff/debuff effect takes effect. The Buff itself is passed as a parameter.
signal began(buff: Buff)
## Emitted when the buff/debuff ends. The Buff itself is passed as a parameter.
signal ended(buff: Buff)

## Sets the [param amount] and [param duration].
func _init(amount: int, duration: float):
	self.amount = amount
	self.duration = duration

## Adds the Buff to a given [param stat].
func apply_to_stat(stat: CharacterStat) -> void:
	target_stat = stat
	# Buff will actually start after the added_buff signal is emitted by the stat
	target_stat.added_buff.connect(_on_added_buff)
	ended.connect(target_stat.remove_buff)
	target_stat.add_buff(self)

## Instantiates [member Buff.duration_timer] and adds it as a child of the Buff.
func _create_duration_timer() -> void:
	duration_timer = Timer.new()
	add_child(duration_timer)
	duration_timer.one_shot = true
	duration_timer.wait_time = duration
	duration_timer.timeout.connect(_on_duration_timer_timeout)

## Emits the [member Buff.ended] signal on duration timer timeout.
func _on_duration_timer_timeout():
	ended.emit(self)
	print("%s buff (%d for %f sec) has ended." % [target_stat.stat_name, amount, duration])

## Checks if the [param buff] parameter is equal to this specific Buff and starts the Buff.
func _on_added_buff(buff: Buff) -> void:
	if buff == self:
		begin()

## Creates and starts [member Buff.duration_timer] and emits the [member Buff.began] signal.
func begin() -> void:
	_create_duration_timer()
	duration_timer.start()
	began.emit(self)
	print("%s buff (%d for %f sec) has begun." % [target_stat.stat_name, amount, duration])
