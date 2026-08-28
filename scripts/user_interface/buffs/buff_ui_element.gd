class_name BuffUIElement
extends Panel

const BUFF_STYLEBOX := preload(
	"res://assets/user_interface/styles/buffs/buff_panel.tres"
)
const DEBUFF_STYLEBOX := preload(
	"res://assets/user_interface/styles/buffs/debuff_panel.tres"
)
const STAT_ICONS: Dictionary[String, Texture2D] = {
	"damage": preload("res://assets/sprites/characters/particles/sword.png"),
	"health": preload("res://assets/sprites/characters/particles/heart.png"),
	"speed": preload("res://assets/user_interface/misc/arrow_up.png"),
	"armor": preload("res://assets/sprites/characters/particles/shield.png")
}

var buff: Buff

@onready var _stat_icon: TextureRect = get_node("StatIcon")
@onready var _duration_rect: ColorRect = get_node("DurationRect")


func _ready() -> void:
	if not is_instance_valid(buff):
		return
	buff.ended.connect(queue_free.unbind(1))
	_load_stat_icon(buff)
	_update_panel_color(buff)
	_play_duration_tween(buff)
	_update_tooltip(buff)


func _load_stat_icon(stat_buff: Buff) -> void:
	var stat: CharacterStat = stat_buff.target_stat
	var stat_name: String = stat.stat_name
	var lwr: String = stat_name.to_lower()
	if lwr in STAT_ICONS.keys():
		var icon: Texture2D = STAT_ICONS[lwr]
		_stat_icon.texture = icon


func _update_panel_color(stat_buff: Buff) -> void:
	if stat_buff.amount >= 0:
		add_theme_stylebox_override("panel", BUFF_STYLEBOX)
	else:
		add_theme_stylebox_override("panel", DEBUFF_STYLEBOX)


func _play_duration_tween(stat_buff: Buff) -> void:
	var tween: Tween = _duration_rect.create_tween()
	tween.tween_property(_duration_rect, "size:y", size.y, stat_buff.duration)


func _update_tooltip(stat_buff: Buff) -> void:
	var text: String = ""
	var symbol: String = "+"
	if stat_buff.amount < 0:
		symbol = "-"
	text += symbol
	text += str(stat_buff.amount) + " " + stat_buff.target_stat.stat_name + \
			" for " + str(stat_buff.duration) + " seconds"
	tooltip_text = text
