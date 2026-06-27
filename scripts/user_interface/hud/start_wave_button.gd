class_name StartWaveButton
extends GlowingButton


func _ready() -> void:
	super()
	pressed.connect(WorldManager._on_spawn_wave_button_pressed)
	WorldManager.wave_started.connect(hide)
	WorldManager.wave_ended.connect(show)
	WorldManager.wave_ended.connect(_show_highlight)
	WorldManager.final_wave_finished.connect(hide)
