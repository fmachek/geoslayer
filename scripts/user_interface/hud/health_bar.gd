class_name HealthBar
extends ProgressBar
## Represents a health bar used by [Character]s and such.

var _character: Character
var _fade_out_tween: Tween

@onready var _health_label: Label = $HealthLabel
@onready var _visibility_timer: Timer = $VisibilityTimer


## Sets the [HealthBar] up to display a [param character]'s health.
func set_up(character: Character) -> void:
	self._character = character
	_update_label()
	_character.health_changed.connect(_update_label.unbind(2))
	_character.health_changed.connect(_show_self.unbind(2))
	_character.max_health_changed.connect(_update_label.unbind(2))
	_character.max_health_changed.connect(_show_self.unbind(2))


func _update_label() -> void:
	var health: Health = _character.health
	var max_health: int = health.max_value_after_buffs
	var current_health: int = health.current_value
	_health_label.text = "%d/%d" % [current_health, max_health]
	max_value = max_health
	value = current_health


func _on_visibility_timer_timeout() -> void:
	if _fade_out_tween:
		_fade_out_tween.kill()
	modulate.a = 1
	_fade_out_tween = create_tween()
	_fade_out_tween.tween_property(self, "modulate:a", 0, 0.25)
	_fade_out_tween.tween_callback(hide)


func _show_self() -> void:
	if _fade_out_tween:
		_fade_out_tween.kill()
	modulate.a = 1
	show()
	_visibility_timer.start()
