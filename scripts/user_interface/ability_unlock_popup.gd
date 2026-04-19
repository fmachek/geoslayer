class_name AbilityUnlockPopup
extends VBoxContainer
## Represents a popup which appears when the player unlocks
## a new [Ability]. It then fades out and disappears.

var _fade_tween: Tween

@onready var _name_label: Label = $NameLabel
@onready var _fade_out_timer: Timer = $FadeOutTimer


func _ready():
	PlayerManager.player_spawned.connect(_on_player_spawned)


## Displays the unlock of an ability with a given [param ability_name].
func show_unlock(ability_name: String):
	show()
	modulate.a = 1
	_name_label.text = ability_name
	_fade_out_timer.start()


func _fade_out():
	if _fade_tween:
		_fade_tween.kill()
		modulate.a = 1
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0, 1)
	_fade_tween.tween_callback(hide)


func _on_fade_out_timer_timeout() -> void:
	_fade_out()


func _on_player_spawned(player: PlayerCharacter):
	player.new_ability_unlocked.connect(_on_ability_unlocked)


func _on_ability_unlocked(ability: Ability):
	show_unlock(ability.ability_name)
