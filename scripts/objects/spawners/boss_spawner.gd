class_name BossSpawner
extends CharacterSpawner
## Represents a boss spawner. It displays a label explaining that
## it spawns a boss during the last wave when a [PlayerCharacter]
## comes close to it.

var _can_show_label: bool = true
var _info_label_tween: Tween

@onready var _info_label: Label = $InfoLabel


func _ready() -> void:
	super()
	spawning_character.connect(_hide_info_label.unbind(1))
	spawning_character.connect(_stop_showing_label.unbind(1))


## Spawns a [Character] exactly like [method CharacterSpawner.spawn_character],
## but also connects its [signal Character.died] signal
## to [signal WorldManager.handle_boss_death].
func spawn_character(current_wave: int) -> Character:
	var character := super(current_wave)
	character.died.connect(WorldManager.handle_boss_death)
	return character


func _on_player_detection_area_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter and _can_show_label:
		_show_info_label()


func _on_player_detection_area_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter and _can_show_label:
		_hide_info_label()


func _show_info_label() -> void:
	if _info_label_tween:
		_info_label_tween.kill()
	_info_label.modulate.a = 0
	_info_label_tween = create_tween()
	_info_label_tween.tween_property(_info_label, "modulate:a", 1, 0.25)


func _hide_info_label() -> void:
	if _info_label_tween:
		_info_label_tween.kill()
	_info_label.modulate.a = 1
	_info_label_tween = create_tween()
	_info_label_tween.tween_property(_info_label, "modulate:a", 0, 0.25)


func _stop_showing_label() -> void:
	_can_show_label = false
