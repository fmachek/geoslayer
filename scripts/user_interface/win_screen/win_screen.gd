class_name WinScreen
extends Control
## Represents UI which appears when the player wins the game. It plays
## a visual effect where XP orbs transfer from the player's achieved level
## to their permanent XP.

const _ORB_SPRITE_SCENE := preload(
		"res://scenes/user_interface/win_screen/xp_orb_sprite.tscn")

@onready var _progress_bar: ProgressBar = %LevelProgressBar
@onready var _level_container: PlayerLevelContainer = %PlayerLevelContainer
@onready var _level_label: Label = %LevelAchievedLabel
@onready var _menu_button: Button = %BackToMenuButton
@onready var _progression_button: Button = %ProgressionButton


func _ready() -> void:
	_menu_button.pressed.connect(GameManager.switch_to_menu)
	_progression_button.pressed.connect(GameManager.switch_to_progression)
	_level_label.text = str(GameManager.level_achieved)
	call_deferred("_play_orb_effect")


func _play_orb_effect() -> void:
	# Get the player xp given after the win
	var last_xp_gained: int = GameManager.last_xp_gained
	
	for i in range(last_xp_gained):
		var orb: TextureRect = _ORB_SPRITE_SCENE.instantiate()
		var random_size: int = randi_range(10, 20)
		orb.size = Vector2(random_size, random_size)
		add_child(orb)
		
		var half_size := Vector2(_level_label.size.x / 2, _level_label.size.y / 2)
		var orb_pos := _level_label.global_position + half_size - Vector2(orb.size.x / 2, 0)
		orb.global_position = orb_pos
		
		var bar_pos := _progress_bar.global_position
		var half_x_size := Vector2(_progress_bar.size.x / 2, 0)
		var offset := Vector2(randi_range(-50, 50), 0)
		var target_pos := bar_pos + half_x_size + offset
		
		var tween := get_tree().create_tween()
		tween.tween_property(orb, "global_position", target_pos, 0.5)
		tween.tween_callback(orb.queue_free)
		tween.tween_callback(func(): _level_container.level.add_xp(1))
		tween.play()
		
		await get_tree().create_timer(0.05).timeout
