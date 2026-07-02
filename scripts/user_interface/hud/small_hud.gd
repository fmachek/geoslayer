class_name SmallHUD
extends VBoxContainer

const BORDER_COLOR: Color = Color("00d600")

var ability_1: Ability
var ability_2: Ability
var dodge: Dodge

@onready var container_1: PanelContainer = $AbilityContainer/Container1
@onready var container_2: PanelContainer = $AbilityContainer/Container2
@onready var container_3: PanelContainer = $AbilityContainer/Container3
@onready var level_label: Label = $LevelLabel


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)
	var stylebox_1 := StyleBoxFlat.new()
	var stylebox_2 := StyleBoxFlat.new()
	var stylebox_3 := StyleBoxFlat.new()
	for sb: StyleBoxFlat in [stylebox_1, stylebox_2, stylebox_3]:
		sb.bg_color = Color("00000054")
		sb.border_color = BORDER_COLOR
		sb.set_border_width_all(2)
	container_1.add_theme_stylebox_override("panel", stylebox_1)
	container_2.add_theme_stylebox_override("panel", stylebox_2)
	container_3.add_theme_stylebox_override("panel", stylebox_3)


func _on_player_spawned(player: PlayerCharacter) -> void:
	dodge = player.dodge
	connect_to_dodge()
	
	if dodge.is_cooldown:
		_on_dodge_cd_started()
	else:
		_on_dodge_cd_ended()
	
	player.ability1_changed.connect(_on_ability_1_changed)
	player.ability2_changed.connect(_on_ability_2_changed)
	player.level.level_changed.connect(
		func(new_level: int):
			_on_level_changed(new_level, player.level.current_xp, player.level.required_xp)
	)
	player.level.current_xp_changed.connect(
		func(new_xp: int):
			_on_level_changed(player.level.current_level, new_xp, player.level.required_xp)
	)
	player.level.required_xp_changed.connect(
		func(new_xp: int):
			_on_level_changed(player.level.current_level, player.level.current_xp, new_xp)
	)
	
	_on_ability_1_changed(player.ability1)
	_on_ability_2_changed(player.ability2)
	_on_level_changed(
		player.level.current_level, player.level.current_xp, player.level.required_xp
	)


func connect_to_ability_1(ability: Ability) -> void:
	ability.cooldown_started.connect(_on_cd_1_started)
	ability.cooldown_ended.connect(_on_cd_1_ended)


func connect_to_ability_2(ability: Ability) -> void:
	ability.cooldown_started.connect(_on_cd_2_started)
	ability.cooldown_ended.connect(_on_cd_2_ended)


func connect_to_dodge() -> void:
	dodge.cooldown_started.connect(_on_dodge_cd_started)
	dodge.cooldown_ended.connect(_on_dodge_cd_ended)


func _on_cd_1_started() -> void:
	container_1.get_node("Overlay").show()
	container_1.get_theme_stylebox("panel").border_color = Color(0.0, 0.0, 0.0, 0.0)


func _on_cd_1_ended() -> void:
	if not ability_1.is_cooldown:
		container_1.get_node("Overlay").hide()
		container_1.get_theme_stylebox("panel").border_color = BORDER_COLOR


func _on_cd_2_started() -> void:
	container_2.get_node("Overlay").show()
	container_2.get_theme_stylebox("panel").border_color = Color(0.0, 0.0, 0.0, 0.0)


func _on_cd_2_ended() -> void:
	if not ability_2.is_cooldown:
		container_2.get_node("Overlay").hide()
		container_2.get_theme_stylebox("panel").border_color = BORDER_COLOR


func _on_dodge_cd_started() -> void:
	container_3.get_node("Overlay").show()
	container_3.get_theme_stylebox("panel").border_color = Color(0.0, 0.0, 0.0, 0.0)


func _on_dodge_cd_ended() -> void:
	if not dodge.is_cooldown:
		container_3.get_node("Overlay").hide()
		container_3.get_theme_stylebox("panel").border_color = BORDER_COLOR


func _on_ability_1_changed(new_ability: Ability) -> void:
	if ability_1:
		if ability_1.cooldown_started.is_connected(_on_cd_1_started):
			ability_1.cooldown_started.disconnect(_on_cd_1_started)
		if ability_1.cooldown_ended.is_connected(_on_cd_1_ended):
			ability_1.cooldown_ended.disconnect(_on_cd_1_ended)
	ability_1 = new_ability
	if new_ability == null:
		container_1.hide()
		return
	connect_to_ability_1(new_ability)
	if new_ability.is_cooldown:
		_on_cd_1_started()
	else:
		_on_cd_1_ended()
	container_1.show()


func _on_ability_2_changed(new_ability: Ability) -> void:
	if ability_2:
		if ability_2.cooldown_started.is_connected(_on_cd_2_started):
			ability_2.cooldown_started.disconnect(_on_cd_2_started)
		if ability_2.cooldown_ended.is_connected(_on_cd_2_ended):
			ability_2.cooldown_ended.disconnect(_on_cd_2_ended)
	ability_2 = new_ability
	if new_ability == null:
		container_2.hide()
		return
	connect_to_ability_2(new_ability)
	if new_ability.is_cooldown:
		_on_cd_2_started()
	else:
		_on_cd_2_ended()
	container_2.show()


func _on_level_changed(new_level: int, current_xp: int, required_xp: int) -> void:
	level_label.text = "Level %d (%d/%dXP)" % [new_level, current_xp, required_xp]
