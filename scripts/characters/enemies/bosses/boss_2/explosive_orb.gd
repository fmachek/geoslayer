class_name ExplosiveOrb
extends Enemy

var explosion_time: float = 15.0
var explosion_base_damage: int = 500

# Casts explosion
var blast: Blast
var blast_radius: float = 3000.0

var _progress_bar_tween: Tween

@onready var _explosion_timer: Timer = $ExplosionTimer
@onready var _progress_bar: ProgressBar = $ExplosionProgressBar


func _ready() -> void:
	super()
	health.regen_amount = 0
	_setup_blast()
	_set_progress_bar_stylebox()
	_explosion_timer.wait_time = explosion_time
	_explosion_timer.start()
	_tween_progress_bar()


func _process(delta: float) -> void:
	pass


# Overridden method to ensure the orb doesn't move, get knocked
# back and so on.
func _physics_process(delta: float) -> void:
	pass


# Empty, Blast is only equipped when exploding.
func _load_abilities() -> void:
	pass


# Drops nothing.
func generate_drop_pool() -> void:
	pass


func explode() -> void:
	equip_ability(blast)
	blast.cast()
	die()


func _on_explosion_timer_timeout() -> void:
	if health.current_value > 0:
		explode()


func _setup_blast() -> void:
	blast = Blast.new()
	blast.base_damage = explosion_base_damage
	blast.final_radius = blast_radius
	blast.cast_time = 0.0
	blast.life_time = 0.5


func _set_progress_bar_stylebox() -> void:
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = draw_color
	_progress_bar.add_theme_stylebox_override("fill", stylebox)


func _tween_progress_bar() -> void:
	if _progress_bar_tween:
		_progress_bar_tween.kill()
	_progress_bar.value = 0.0
	_progress_bar_tween = create_tween()
	var max_value: float = _progress_bar.max_value
	_progress_bar_tween.tween_property(_progress_bar, "value", max_value, explosion_time)
	_progress_bar_tween.tween_callback(_progress_bar.hide)
