class_name HealthBar
extends ProgressBar

@onready var health_label: Label = $HealthLabel
@onready var character: Character = $".."
@onready var visibility_timer: Timer = $VisibilityTimer

var fade_out_tween: Tween

func set_up() -> void:
	character.health_changed.connect(update_label)
	character.health_changed.connect(show_self)
	character.max_health_changed.connect(update_label)

func update_label(old_health, new_health) -> void:
	var label: Label = $HealthLabel
	
	var max_health = character.health.max_value_after_buffs
	var health = character.health.current_value
	
	label.text = str(health) + "/" + str(max_health)
	
	max_value = max_health
	value = health

func _on_visibility_timer_timeout() -> void:
	if fade_out_tween:
		fade_out_tween.kill()
	self.modulate.a = 1
	fade_out_tween = create_tween()
	fade_out_tween.tween_property(self, "modulate:a", 0, 0.25)
	fade_out_tween.tween_callback(hide)

func show_self(old_value, new_value) -> void:
	if fade_out_tween:
		fade_out_tween.kill()
	self.modulate.a = 1
	show()
	visibility_timer.start()
