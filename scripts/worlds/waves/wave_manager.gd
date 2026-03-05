class_name WaveManager
extends Node

var current_wave: int = 0
var time_until_wave_end: int = 0 # Time in seconds
@onready var wave_timer: Timer = $WaveTimer

signal current_wave_changed(wave: int)
signal time_until_wave_end_changed(time: int)
signal wave_started()
signal wave_ended()

func start_wave() -> void:
	current_wave += 1
	wave_started.emit()
	current_wave_changed.emit(current_wave)
	
	time_until_wave_end = 30 # Each wave lasts 30 seconds
	time_until_wave_end_changed.emit(time_until_wave_end)
	wave_timer.start()
	
	print("Wave " + str(current_wave) + " started!")

func _on_wave_timer_timeout() -> void:
	time_until_wave_end -= 1
	time_until_wave_end_changed.emit(time_until_wave_end)
	if time_until_wave_end == 0:
		end_wave()

func end_wave() -> void:
	wave_ended.emit()
	wave_timer.stop()
