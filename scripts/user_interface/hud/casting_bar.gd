class_name CastingBar
extends ProgressBar

@onready var label: Label = get_node("AbilityNameLabel")

var _current_ability: Ability
var _value_tween: Tween


func _ready() -> void:
	PlayerManager.player_spawned.connect(_on_player_spawned)


func update_label(ability_name: String) -> void:
	label.text = ability_name


func _on_player_spawned(player: PlayerCharacter) -> void:
	player.started_casting.connect(_on_player_started_casting)


func _on_player_started_casting(ability: Ability) -> void:
	if _current_ability:
		if _current_ability.finished_casting.is_connected(_stop.bind(_current_ability)):
			_current_ability.finished_casting.disconnect(_stop.bind(_current_ability))
	_current_ability = ability
	ability.finished_casting.connect(_stop.bind(ability))
	update_label(ability.ability_name)
	_tween_value(ability.cast_time)
	show()


func _stop(calling_ability: Ability) -> void:
	if calling_ability == _current_ability:
		hide()


func _tween_value(cast_time: float) -> void:
	if _value_tween:
		_value_tween.kill()
	_value_tween = create_tween()
	value = min_value
	_value_tween.tween_property(self, "value", max_value, cast_time)
