# A buff or debuff temporarily changes a character stat. It's considered a buff if it's
# a positive effect and a debuff if it's a negative effect.

class_name Buff
extends Node

var target_stat: CharacterStat # Stat which will be modified
var amount: int # Amount by which the stat will be modified
var duration: float # How long the buff lasts
var duration_timer: Timer

signal began(buff: Buff) # Emitted when the buff begins
signal ended(buff: Buff) # Emitted when the buff ends

func _init(amount: int, duration: float):
	self.amount = amount
	self.duration = duration

func create_timer() -> void:
	duration_timer = Timer.new()
	add_child(duration_timer)
	duration_timer.one_shot = true
	duration_timer.wait_time = duration
	duration_timer.timeout.connect(_on_timer_timeout)

func apply(target_stat: CharacterStat) -> void:
	self.target_stat = target_stat
	target_stat.added_buff.connect(_on_added_buff)
	connect_duration_signals()
	began.emit(self)

func _on_timer_timeout():
	ended.emit(self)
	print(target_stat.stat_name + " buff (" + str(amount) + " for " + str(duration) + "sec) has ended.")

# Connects the 'began' and 'ended' signals to the CharacterStat 'add_buff' and 'remove_buff'
# functions respectively.
func connect_duration_signals() -> void:
	began.connect(target_stat.add_buff)
	ended.connect(target_stat.remove_buff)

func _on_added_buff(buff: Buff) -> void:
	if buff == self:
		start_buff()

func start_buff() -> void:
	create_timer()
	duration_timer.start()
	print(target_stat.stat_name + " buff (" + str(amount) + " for " + str(duration) + "sec) has begun.")
