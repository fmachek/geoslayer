class_name NextWaveLabel
extends Label
## Represents a label which shows the number of the next wave.
## If there are no more waves, it is hidden.


func _ready() -> void:
	_update_text(0)
	WorldManager.wave_changed.connect(_update_text)


func _update_text(current_wave: int) -> void:
	var next_wave := current_wave + 1
	var world: World = WorldManager.current_world
	if is_instance_valid(world):
		var last_wave := world.wave_manager.max_waves
		if next_wave > last_wave:
			hide()
			return
	text = "Next wave: %d" % (current_wave + 1)
