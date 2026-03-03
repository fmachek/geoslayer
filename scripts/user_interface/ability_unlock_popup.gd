class_name AbilityUnlockPopup
extends VBoxContainer

var fade_tween: Tween

func _ready():
	PlayerManager.player_spawned.connect(_on_player_spawned)

func show_unlock(ability_name: String):
	show()
	modulate.a = 1
	$NameLabel.text = ability_name
	$FadeOutTimer.start()

func fade_out():
	if fade_tween:
		fade_tween.kill()
		modulate.a = 1
	fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0, 1)
	fade_tween.tween_callback(hide)

func _on_fade_out_timer_timeout() -> void:
	fade_out()

func _on_player_spawned(player: PlayerCharacter):
	player.new_ability_unlocked.connect(_on_ability_unlocked)

func _on_ability_unlocked(ability: Ability):
	show_unlock(ability.ability_name)
