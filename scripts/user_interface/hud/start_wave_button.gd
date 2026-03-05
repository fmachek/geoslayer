class_name StartWaveButton
extends Button

func _ready() -> void:
	pressed.connect(WorldManager._on_spawn_wave_button_pressed)
	WorldManager.wave_started.connect(hide)
	WorldManager.wave_ended.connect(show)
