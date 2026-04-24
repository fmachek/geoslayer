class_name EnemiesTab
extends PanelContainer
## Represents a tab in the UI which displays information about
## enemies who spawn in the currently loaded world.

const _SECTION_SCENE := preload(
		"res://scenes/user_interface/large_tab_container/enemies_tab/enemy_section.tscn")

@onready var _section_container: VBoxContainer = %EnemySectionContainer


func _ready() -> void:
	var world: World = WorldManager.current_world
	if is_instance_valid(world):
		_load_all_world_enemies(world)
	else:
		WorldManager.world_loaded.connect(_load_all_world_enemies)


## Loads information about an enemy with a given [param enemy_name].
func load_enemy(enemy_name: String) -> void:
	var section: EnemySection = _SECTION_SCENE.instantiate()
	var method_name := "load_" + enemy_name.to_lower()
	section.call(method_name)
	_section_container.add_child(section)


func _load_all_world_enemies(world: World) -> void:
	var enemy_names: Array[String] = world.enemy_names
	for enemy in enemy_names:
		load_enemy(enemy)


func _on_close_button_pressed() -> void:
	hide()
