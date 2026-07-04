extends Node
## This autoload handles important processes such as player spawning and allows for
## easier access to the player from far away in the scene tree via [member current_player].
## It also emits signals such as [member player_died] which allow nodes to detect
## player deaths without having to connect to the player directly.

## Emitted when the player is spawned into the world.
signal player_spawned(player: PlayerCharacter)
## Emitted when the player dies.
signal player_died(player: PlayerCharacter)
## Emitted when the amount of perk points available to the player changes.
signal perk_points_changed(points: int)

const _PLAYER_SCENE_PATH := "res://scenes/characters/player/player_character.tscn"
const _PLAYER_SCENE := preload(_PLAYER_SCENE_PATH)
const _BUFF_LABEL_SCENE := preload(
	"res://scenes/user_interface/world_labels/buff_pickup_label.tscn"
)

## The [PlayerCharacter] currently loaded in the world.
var current_player: PlayerCharacter


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	SignalBus.selected_buff.connect(apply_buff_to_player.unbind(1))


## Spawns the [PlayerCharacter] at a given position.
func spawn_player(position: Vector2) -> void:
	current_player = _PLAYER_SCENE.instantiate()
	WorldManager.current_world.add_child(current_player)
	current_player.name = "PlayerCharacter"
	current_player.global_position = position
	_connect_player_signals()
	player_spawned.emit(current_player)


## Attempts to spend and apply a perk point to a [param stat].
## Fails if the player doesn't have any perk points.
func apply_perk_point(stat: CharacterStat) -> void:
	if current_player:
		current_player.apply_perk_point(stat)


## Attempts to apply an [param amount] of perk points to a
## [param stat].
func apply_perk_point_stack(stat: CharacterStat, amount: int) -> void:
	for i in range(amount):
		apply_perk_point(stat)


# Connects current player's important signals to functions inside this script.
func _connect_player_signals() -> void:
	current_player.died.connect(_on_player_died)
	current_player.died.connect(GameManager._on_player_died)
	current_player.perk_points_available_changed.connect(
			func(points: int): perk_points_changed.emit(points))


func _on_player_died() -> void:
	player_died.emit(current_player)
	current_player.died.disconnect(_on_player_died)
	current_player = null


# Reacts to attempts to equip an Ability with a given name in slot 1.
# Checks if the Ability has been unlocked by the player. If so,
# the Ability in slot 1 is replaced.
func _on_UI_ability1_equip(ability_name: String) -> void:
	if not current_player:
		return
	for ability in current_player.unlocked_abilities:
		if ability.ability_name == ability_name:
			current_player.replace_ability1(ability)


# Reacts to attempts to equip an Ability with a given name in slot 2.
# Checks if the Ability has been unlocked by the player. If so,
# the Ability in slot 2 is replaced.
func _on_UI_ability2_equip(ability_name: String) -> void:
	if not current_player:
		return
	for ability in current_player.unlocked_abilities:
		if ability.ability_name == ability_name:
			current_player.replace_ability2(ability)


# Replaces the player's ability slot 1 with null (unequip).
func _on_UI_unequip_slot1_pressed() -> void:
	if not current_player:
		return
	current_player.replace_ability1(null)


# Replaces the player's ability slot 2 with null (unequip).
func _on_UI_unequip_slot2_pressed() -> void:
	if not current_player:
		return
	current_player.replace_ability2(null)


# Replaces both of the player's ability slots with null (unequip).
func _on_UI_unequip_all_pressed() -> void:
	if not current_player:
		return
	current_player.replace_ability1(null)
	current_player.replace_ability2(null)


func apply_buff_to_player(buff: Buff, stat_name: String) -> void:
	if not is_instance_valid(current_player):
		return
	var stat: CharacterStat = current_player.get_node("CharacterStats").get_node(stat_name)
	if not is_instance_valid(stat):
		return
	buff.apply_to_stat(stat)
	_spawn_buff_pickup_label(buff)


func _spawn_buff_pickup_label(buff: Buff) -> void:
	if not is_instance_valid(current_player):
		return
	var buff_pickup_label: BuffPickupLabel = _BUFF_LABEL_SCENE.instantiate()
	current_player.add_child(buff_pickup_label)
	var offset := Vector2(randi_range(-30, 30), randi_range(-30, 30))
	buff_pickup_label.global_position = current_player.global_position \
			+ offset - Vector2(buff_pickup_label.size.x / 2, buff_pickup_label.size.y / 2)
	buff_pickup_label.load_buff(buff)
	buff_pickup_label.play_tween()
