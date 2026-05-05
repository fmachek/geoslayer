class_name WaveManager
extends Node
## Manages waves of incoming enemies in a [World].

## Emitted when [member current_wave] changes.
signal current_wave_changed(wave: int)
## Emitted when a new wave starts.
signal wave_started()
## Emitted when a wave ends.
signal wave_ended()
## Emitted when the final wave starts.
signal final_wave_started()
## Emitted when the final wave ends.
signal final_wave_finished()
## Emitted after entering the scene tree and when starting a new wave.
signal alert_next_wave(next_wave: int, exceeds_max: bool)

## Total amount of waves.
@export var max_waves: int = 5

## Number of the current wave.
var current_wave: int = 0: set = set_current_wave
## Array of enemies currently registered.
var enemies: Array[Enemy] = []


func _ready() -> void:
	alert_next_wave.emit(current_wave + 1, false)


## Starts a wave.
func start_wave() -> void:
	if current_wave == max_waves:
		return
	current_wave += 1
	if current_wave == max_waves:
		final_wave_started.emit()
	wave_started.emit()
	var next_wave: int = current_wave + 1
	var exceeds_max: bool = false
	if next_wave > max_waves:
		exceeds_max = true
	alert_next_wave.emit(next_wave, exceeds_max)
	
	print("Wave %d started!" % current_wave)


## Ends the current wave.
func end_wave() -> void:
	wave_ended.emit()
	if current_wave == max_waves:
		final_wave_finished.emit()


## Registers an [Enemy]. When it dies, it is considered
## when checking whether a wave should end because there
## are no enemies remaining.
func register_enemy(enemy: Enemy) -> void:
	if enemy in enemies:
		return
	enemies.append(enemy)
	enemy.died.connect(func(): unregister_enemy(enemy))


## Unregisters an [Enemy]. The amount of currently
## registered enemies is checked. If there are no more enemies,
## the current wave ends.
func unregister_enemy(enemy: Enemy) -> void:
	if not enemy in enemies:
		return
	enemies.erase(enemy)
	if enemy.died.is_connected(unregister_enemy):
		enemy.died.disconnect(unregister_enemy)
	_check_enemy_amount()


## Sets [member current_wave].
func set_current_wave(value: int) -> void:
	if value < 0 or value > max_waves:
		return
	current_wave = value
	current_wave_changed.emit(value)


func _check_enemy_amount() -> void:
	var enemy_amount := len(enemies)
	if enemy_amount == 0:
		end_wave()
