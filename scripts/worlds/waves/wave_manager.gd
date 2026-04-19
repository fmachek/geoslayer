class_name WaveManager
extends Node
## Manages waves of incoming enemies in a [World].

## Emitted when [member current_wave] changes.
signal current_wave_changed(wave: int)
## Emitted when [member time_until_wave_end] changes.
signal time_until_wave_end_changed(time: int)
## Emitted when a new wave starts.
signal wave_started()
## Emitted when a wave ends.
signal wave_ended()
## Emitted when the final wave ends.
signal final_wave_finished()

## Time each wave takes in seconds.
@export var time_per_wave: int = 30
## Total amount of waves.
@export var max_waves: int = 5

## Number of the current wave.
var current_wave: int = 0: set = set_current_wave
## Time until the current wave ends in seconds.
var time_until_wave_end: int = 0: set = set_time_until_wave_end # TODO: this variable could be renamed...

@onready var _wave_timer: Timer = $WaveTimer


## Starts a wave. The last wave ends instantly (that should be
## the boss wave which has no timer).
func start_wave() -> void:
	if current_wave == max_waves:
		return
	current_wave += 1
	wave_started.emit()
	
	if current_wave != max_waves:
		time_until_wave_end = time_per_wave
		_wave_timer.start()
	else:
		end_wave()
	
	print("Wave %d started!" % current_wave)


## Ends the wave.
func end_wave() -> void:
	wave_ended.emit()
	_wave_timer.stop()
	if time_until_wave_end != 0:
		time_until_wave_end = 0
	if current_wave == max_waves:
		final_wave_finished.emit()


## Sets [member current_wave].
func set_current_wave(value: int) -> void:
	if value < 0:
		return
	current_wave = value
	current_wave_changed.emit(value)


## Sets [member time_until_wave_end].
func set_time_until_wave_end(value: int) -> void:
	if value < 0:
		return
	time_until_wave_end = value
	time_until_wave_end_changed.emit(value)


func _on_wave_timer_timeout() -> void:
	time_until_wave_end -= 1
	if time_until_wave_end == 0:
		end_wave()
