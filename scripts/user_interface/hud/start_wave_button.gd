class_name StartWaveButton
extends GlowingButton


func _ready() -> void:
	super()
	pressed.connect(WorldManager._on_spawn_wave_button_pressed)
	WorldManager.wave_started.connect(hide)
	WorldManager.wave_ended.connect(show_and_update)
	WorldManager.wave_ended.connect(_show_highlight)
	WorldManager.final_wave_finished.connect(hide)
	show_and_update.call_deferred()


func show_and_update() -> void:
	var world: World = WorldManager.current_world
	var wave_manager: WaveManager = world.wave_manager
	var next_wave: int = wave_manager.current_wave + 1
	if next_wave <= wave_manager.max_waves:
		text = "Start wave %d" % next_wave
	show()
