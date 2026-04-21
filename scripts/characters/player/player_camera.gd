class_name PlayerCamera
extends Camera2D
## Represents the player camera which allows zooming in and out using
## the mouse wheel.

## Steps of zoom the camera is bound to.
var zoom_steps: Array[Vector2] = [
		Vector2(0.6, 0.6),
		Vector2(0.75, 0.75),
		Vector2.ONE,
		Vector2(1.5, 1.5)
	]

var _zoom_tween: Tween
var _zooming: bool = false
var _current_zoom: int = 2


func _ready() -> void:
	_current_zoom = 2
	zoom = zoom_steps[_current_zoom]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventMouse:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()


## Zooms in (moves to the next step in [member zoom_steps]).
func zoom_in() -> void:
	if _zooming:
		return
	if _current_zoom + 1 > (len(zoom_steps) - 1):
		return
	_current_zoom += 1
	_zoom()


## Zooms out (moves to the previous step in [member zoom_steps]).
func zoom_out() -> void:
	if _zooming:
		return
	if _current_zoom - 1 < 0:
		return
	_current_zoom -= 1
	_zoom()


func _zoom() -> void:
	_zooming = true
	if _zoom_tween:
		_zoom_tween.kill()
	var end_zoom: Vector2 = zoom_steps[_current_zoom]
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(self, "zoom", end_zoom, 0.1)
	_zoom_tween.tween_callback(func(): _zooming = false)
