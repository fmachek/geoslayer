class_name CharacterSpawner
extends Node2D

## Represents a spawner which spawns characters on certain waves.

#region @export variables
## Scene of the [Character] being spawned.
@export var character_scene := preload("res://scenes/characters/character.tscn")
## Fill color of the [CharacterSpawner] shape.
@export var draw_color := Color(0.447, 0.447, 0.447, 1.0)
## Outline color of the [CharacterSpawner] shape.
@export var outline_color := Color(0.352, 0.352, 0.352, 1.0)
## Used by the [CharacterSpawner] to determine whether a [Character] should
## be spawned on specific waves. For example, if the array contains
## integers 1, 3 and 5, the [CharacterSpawner] will trigger on each
## one of those waves.
@export var spawn_waves: PackedInt32Array
#endregion


func _draw() -> void:
	var radius: int = $Area2D/CollisionShape2D.shape.radius
	draw_circle(Vector2.ZERO, radius, draw_color)
	var outline_width: int = radius/8
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, outline_color, outline_width, true)


## Spawns a [Character] instantiated from
## [member CharacterSpawner.character_scene].
func spawn_character(current_wave: int) -> void:
	var character: Character = character_scene.instantiate()
	character.global_position = global_position
	get_parent().add_child(character)
	call_deferred("_change_character_level", character, current_wave)
	call_deferred("_fill_character_health", character)
	if character is Boss:
		character.died.connect(WorldManager.handle_boss_death)


# Checks if the new wave is in the spawn_waves array.
# If it is, then a character shold be spawned.
func _on_wave_changed(wave: int) -> void:
	if wave in spawn_waves:
		spawn_character(wave)


func _change_character_level(character: Character, level: int) -> void:
	character.level.current_level = level


func _fill_character_health(character: Character) -> void:
	character.heal(character.health.max_value_after_buffs)
