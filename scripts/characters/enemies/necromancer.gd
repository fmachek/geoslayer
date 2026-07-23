class_name Necromancer
extends Enemy

const CONN_SCENE := preload(
	"res://scenes/particle_effects/necromancer/necromancer_connection.tscn"
)
const GHOST_SCENE := preload(
	"res://scenes/characters/enemies/ghost.tscn"
)

var connections: Dictionary[Enemy, NecromancerConnection] = {}


func _load_abilities() -> void:
	var storm := Storm.new()
	storm.zone_radius = 250.0
	storm.zone_duration = 15.0
	storm.speed_debuff_amount = 0.0
	storm.cooldown = 5.0
	_load_ability(storm)


func _check_character_range_entered(body: Node2D) -> void:
	if body is not Enemy:
		return
	if body is Ghost: # Prevent infinite ghost spawning
		return
	if body == self:
		return
	if not body.died.is_connected(_handle_unit_death.bind(body)):
		body.died.connect(_handle_unit_death.bind(body))
		_create_connection(body)


func _check_character_range_exited(body: Node2D) -> void:
	if body is not Enemy:
		return
	if body.died.is_connected(_handle_unit_death.bind(body)):
		body.died.disconnect(_handle_unit_death.bind(body))
		_remove_connection(body)


func _handle_unit_death(unit: Enemy) -> void:
	_remove_connection(unit)
	_spawn_ghost_on_unit(unit)


func _create_connection(unit: Enemy) -> void:
	var connection: NecromancerConnection = CONN_SCENE.instantiate()
	connection.load_characters(self, unit)
	add_child(connection)
	connections[unit] = connection


func _remove_connection(unit: Enemy) -> void:
	var connection: NecromancerConnection = connections.get(unit)
	if connection:
		connections.erase(unit)
		connection.queue_free()


func _spawn_ghost_on_unit(unit: Enemy) -> void:
	var ghost: Ghost = GHOST_SCENE.instantiate()
	ghost.initial_level = unit.level.current_level
	ghost.global_position = unit.global_position
	WorldManager.current_world.call_deferred("add_child", ghost)
