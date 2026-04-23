class_name WaveTimeLabel
extends Label
## Represents a label which displays the time until the current
## wave ends.


func _ready() -> void:
	hide()
	WorldManager.time_until_wave_end_changed.connect(_on_wave_time_changed)
	WorldManager.wave_ended.connect(hide)
	WorldManager.wave_started.connect(show)


func _on_wave_time_changed(time: int) -> void:
	text = "Wave ends in %d seconds" % time
