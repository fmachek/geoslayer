class_name BuffContainer
extends PanelContainer

signal selected(selected_buff: Buff, target_stat_name: String)

const STAT_COLORS: Dictionary[String, Color] = {
	"Health": Color("53eb00ff"),
	"Damage": Color("f78200ff"),
	"Speed": Color("ffd000ff")
}

var buff: Buff
var stat_name: String
var was_selected: bool = false

var _original_pos: Vector2
var _hover_pos: Vector2
var _pos_tween: Tween

@onready var amount_label: Label = %AmountLabel
@onready var duration_label: Label = %DurationLabel
@onready var base_label: Label = %BaseLabel
@onready var buffed_label: Label = %BuffedLabel
@onready var bg_particles: CPUParticles2D = $BackgroundParticles


func _ready() -> void:
	var player: PlayerCharacter = PlayerManager.current_player
	var stat: CharacterStat = player.get_node("CharacterStats").get_node(stat_name)
	
	var duration: float = buff.duration
	if duration == 0.0:
		duration_label.text = "permanent buff"
	else:
		duration_label.text = "for %d seconds" % buff.duration
	
	if stat.is_percentage_based:
		amount_label.text = "+%d%% %s" % [buff.amount, stat_name]
		base_label.text = "Base %s: %d%%" % [stat_name, stat.max_value]
		buffed_label.text = "Current buffed %s: %d%%" % [stat_name, stat.max_value_after_buffs]
	else:
		amount_label.text = "+%d %s" % [buff.amount, stat_name]
		base_label.text = "Base %s: %d" % [stat_name, stat.max_value]
		buffed_label.text = "Current buffed %s: %d" % [stat_name, stat.max_value_after_buffs]
	
	_set_stylebox()
	_set_background()
	_set_amount_label_settings()
	_set_amount_label_font_color()
	_set_bg_particles()


func load_buff(new_buff: Buff, target_stat: String) -> void:
	self.buff = new_buff
	self.stat_name = target_stat


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			_handle_selection()


func _handle_selection() -> void:
	if was_selected:
		return
	was_selected = true
	selected.emit(buff, stat_name)


func _on_mouse_entered() -> void:
	bg_particles.show()
	get_theme_stylebox("panel").set_border_width_all(2)
	if not _original_pos:
		_original_pos = position
		_hover_pos = position + Vector2(0, -5)
	_tween_pos(_hover_pos)


func _on_mouse_exited() -> void:
	bg_particles.hide()
	get_theme_stylebox("panel").set_border_width_all(0)
	_tween_pos(_original_pos)


func _tween_pos(target_pos: Vector2) -> void:
	if _pos_tween:
		_pos_tween.kill()
	_pos_tween = create_tween()
	_pos_tween.tween_property(self, "position", target_pos, 0.15)


func _set_bg_particles() -> void:
	if not stat_name:
		return
	if stat_name == "Health":
		bg_particles.texture = load(
			"res://assets/sprites/characters/particles/heart.png"
		)
		bg_particles.scale_amount_min = 0.15
		bg_particles.scale_amount_max = 0.3
	elif stat_name == "Damage":
		bg_particles.texture = load(
			"res://assets/sprites/characters/particles/sword.png"
		)
		bg_particles.scale_amount_min = 0.15
		bg_particles.scale_amount_max = 0.3
	elif stat_name == "Speed":
		bg_particles.texture = load(
			"res://assets/user_interface/misc/arrow_up.png"
		)
		bg_particles.scale_amount_min = 0.3
		bg_particles.scale_amount_max = 0.6
	if stat_name in STAT_COLORS:
		bg_particles.color = STAT_COLORS.get(stat_name)


func _set_stylebox() -> void:
	var bg_stylebox := StyleBoxFlat.new()
	bg_stylebox.bg_color = Color("00000083")
	bg_stylebox.border_color = Color.WHITE
	bg_stylebox.set_content_margin_all(2)
	add_theme_stylebox_override("panel", bg_stylebox)


func _set_background() -> void:
	if not stat_name:
		return
	var stylebox: StyleBoxFlat = get_theme_stylebox("panel")
	if stat_name in STAT_COLORS:
		var color: Color = STAT_COLORS[stat_name]
		stylebox.bg_color = Color(color, 0.25)


func _set_amount_label_settings() -> void:
	var label_settings := LabelSettings.new()
	label_settings.font_size = 24
	label_settings.outline_size = 12
	label_settings.outline_color = Color.BLACK
	amount_label.label_settings = label_settings


func _set_amount_label_font_color() -> void:
	if not stat_name:
		return
	if stat_name in STAT_COLORS:
		var color: Color = STAT_COLORS[stat_name]
		amount_label.label_settings.font_color = color
