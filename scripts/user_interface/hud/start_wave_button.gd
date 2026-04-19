class_name StartWaveButton
extends Button
## Represents a button which triggers a new wave when pressed.


func _ready() -> void:
	pressed.connect(WorldManager._on_spawn_wave_button_pressed)
	WorldManager.wave_started.connect(hide)
	WorldManager.wave_ended.connect(show)
	WorldManager.final_wave_finished.connect(hide)
