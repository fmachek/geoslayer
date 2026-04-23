class_name CurrentWaveLabel
extends Label
## Represents a label which shows the number of the current wave.


func _ready() -> void:
	hide()
	WorldManager.wave_started.connect(show)
	WorldManager.wave_ended.connect(hide)
	WorldManager.wave_changed.connect(_update_text)


func _update_text(current_wave: int) -> void:
	text = "Current wave: %d" % current_wave
