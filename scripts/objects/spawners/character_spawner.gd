class_name CharacterSpawner
extends Node2D
## Represents a spawner which spawns characters on certain waves.

## Emitted when a [Character] is being spawned.
signal spawning_character(char: Character)

#region @export variables
## Scene of the [Character] being spawned.
@export var character_scene := preload("res://scenes/characters/character.tscn")
## Default fill color of the [CharacterSpawner] shape.
@export var draw_color := Color(0.447, 0.447, 0.447, 1.0)
## Default outline color of the [CharacterSpawner] shape.
@export var outline_color := Color(0.352, 0.352, 0.352, 1.0)
## Used by the [CharacterSpawner] to determine whether a [Character] should
## be spawned on specific waves. For example, if the array contains
## integers 1, 3 and 5, the [CharacterSpawner] will trigger on each
## one of those waves.
@export var spawn_waves: PackedInt32Array
#endregion


var current_draw_color: Color
var current_outline_color: Color
var _is_highlighted: bool = false


func _ready() -> void:
	current_draw_color = draw_color
	if not _is_highlighted:
		current_outline_color = outline_color


func _draw() -> void:
	var radius: float = $Area2D/CollisionShape2D.shape.radius
	var outline_width: float = radius / 8
	draw_circle(Vector2.ZERO, radius - outline_width / 2, current_draw_color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, current_outline_color, outline_width, true)


## Spawns a [Character] instantiated from [member character_scene].
func spawn_character(current_wave: int) -> Character:
	var character: Character = character_scene.instantiate()
	spawning_character.emit(character)
	character.global_position = global_position
	character.ready.connect(func(): _on_character_ready(character, current_wave))
	get_parent().add_child(character)
	return character


func _on_character_ready(char: Character, wave: int) -> void:
	_change_character_level(char, wave)
	_fill_character_health(char)


# Checks if the new wave is in the spawn_waves array.
# If it is, then a character shold be spawned.
# The array being empty is also considered as "spawn every wave".
func _on_wave_changed(wave: int) -> void:
	if wave in spawn_waves or spawn_waves.is_empty():
		spawn_character(wave)


func _change_character_level(character: Character, level: int) -> void:
	character.level.current_level = level


func _fill_character_health(character: Character) -> void:
	character.heal(character.health.max_value_after_buffs, false)


func _on_wave_manager_alert_next_wave(next_wave: int, exceeds_max: bool) -> void:
	if exceeds_max:
		_turn_highlight_off()
		return
	if next_wave in spawn_waves or spawn_waves.is_empty():
		_turn_highlight_on()
	else:
		_turn_highlight_off()


func _turn_highlight_on() -> void:
	_is_highlighted = true
	current_outline_color = Color(Color.WHITE, 0.75)
	queue_redraw()


func _turn_highlight_off() -> void:
	_is_highlighted = false
	current_outline_color = outline_color
	queue_redraw()
