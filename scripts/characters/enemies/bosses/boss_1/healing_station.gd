class_name HealingStation
extends Character
## Represents an enemy healing station which continuously heals
## a [Character] until it is destroyed. It was created specifically
## for [Boss1] as part of the [Stations] [Ability]. The [HealingStation]
## also dies if [member healing_target] dies.

## Emitted when the [HealingStation] starts healing its target.
signal started_healing()
## Emitted when the [HealingStation] stops healing its target.
signal stopped_healing()

const _HEAL_LABEL_SCENE := preload(
		"res://scenes/user_interface/world_labels/heal_label.tscn")

## The [Character] being healed.
var healing_target: Character: set = _set_healing_character
## Amount by which the [member healing_target]
## is healed each tick.
var heal_amount: int = 3
var _is_healing: bool = false:
	set(value):
		_is_healing = value
		if value:
			started_healing.emit()
		else:
			stopped_healing.emit()

@onready var _line: Line2D = $HealingLine
@onready var _tick_timer: Timer = $HealTickTimer


## Overridden empty method to ensure that the drop pool is empty.
func generate_drop_pool() -> void:
	pass


func _ready() -> void:
	super()
	started_healing.connect(_line.show)
	stopped_healing.connect(_line.hide)
	if healing_target:
		_start_healing()


func _physics_process(delta: float) -> void:
	if _is_healing:
		var p1 := Vector2(0, 0)
		var p2 := to_local(healing_target.global_position)
		_line.points = PackedVector2Array([p1, p2])


func _draw() -> void:
	super()
	draw_line(Vector2(-15, 0), Vector2(15, 0), outline_color, 5)
	draw_line(Vector2(0, -15), Vector2(0, 15), outline_color, 5)


func _start_healing() -> void:
	_is_healing = true
	_tick_timer.start()


func _stop_healing() -> void:
	_is_healing = false
	_tick_timer.stop()


func _on_target_died() -> void:
	_stop_healing()
	healing_target = null
	die()


func _on_heal_tick_timer_timeout() -> void:
	healing_target.heal(heal_amount)
	var label_offset := Vector2(randi_range(-20, 20), randi_range(-20, 20))
	_spawn_heal_label(heal_amount, healing_target.global_position + label_offset)


func _spawn_heal_label(amount: int, pos: Vector2) -> void:
	var heal_label: DamageLabel = _HEAL_LABEL_SCENE.instantiate()
	get_parent().add_child(heal_label)
	heal_label.load_damage(amount, pos)
	heal_label.play_tween()


func _set_healing_character(char: Character) -> void:
	healing_target = char
	if char:
		healing_target.died.connect(_on_target_died)
