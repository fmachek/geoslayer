class_name SaveInfoContainer
extends MarginContainer
## Represents an UI element which informs the player about the
## outcome of player saving.
##
## [member UserManager.load_status] is checked on ready and
## a label displays information about it. The [SaveInfoContainer]
## slides in, stays for a bit, and slides back out.[br][br]
##
## However, the [SaveInfoContainer] only does this for the first instance that
## calls [method _ready] because of the static [member was_shown] variable. This is because
## the [SaveInfoContainer] should only show up when the main menu is opened for the
## first time (when starting the game).

## Says whether a [SaveInfoContainer] has been shown yet or not.
static var was_shown: bool = false

var _origin: Vector2
var _stay_time: float = 3.0
var _slide_time: float = 0.5
var _pos_tween: Tween

@onready var _label: Label = %SaveInfoLabel


func _ready() -> void:
	if was_shown:
		return
	was_shown = true
	
	var load_status: UserManager.LoadStatus = UserManager.load_status
	if load_status == UserManager.LoadStatus.NOT_FOUND:
		_handle_save_not_found()
	elif load_status == UserManager.LoadStatus.SUCCESS:
		_handle_save_success()
	elif load_status == UserManager.LoadStatus.INCOMPLETE:
		_handle_save_incomplete()
	elif load_status == UserManager.LoadStatus.FAIL:
		_handle_save_failure()


## Slides onto the screen.
func slide_in() -> void:
	global_position = _origin + Vector2(size.x, 0)
	_slide(_origin)


## Slides out of the screen.
func slide_out() -> void:
	var target_pos := _origin + Vector2(size.x, 0)
	global_position = _origin
	_slide(target_pos)


func _slide(target_pos: Vector2) -> void:
	if _pos_tween:
		_pos_tween.kill()
	
	_pos_tween = create_tween()
	_pos_tween.tween_property(self, "global_position", target_pos, _slide_time)


func _handle_save_success() -> void:
	_handle_save("Player data loaded successfully.")


func _handle_save_failure() -> void:
	_handle_save("Failed to load player data.")


func _handle_save_not_found() -> void:
	_handle_save("Player save not found. Creating new save.")


func _handle_save_incomplete() -> void:
	_handle_save("Player save was incomplete.")


func _handle_save(message: String) -> void:
	_label.text = message
	show()
	call_deferred("_trigger_slide")


func _trigger_slide() -> void:
	_origin = global_position
	slide_in()
	get_tree().create_timer(_stay_time).timeout.connect(slide_out)
