class_name BottomHUD
extends MarginContainer

@onready var stats_tab: StatsTab = %StatsTab
@onready var stats_tab_open_button: Button = %StatsTabOpenButton

@onready var ability_container: HBoxContainer = $VBoxContainer/AbilityItemContainer
@onready var level_hud: HBoxContainer = $VBoxContainer/LevelHUD

@onready var small_hud: SmallHUD = %SmallHUD


func _ready() -> void:
	var collapse_hud: bool = ConfigManager.collapse_hud
	if collapse_hud:
		level_hud.hide()
		ability_container.hide()
		small_hud.show()


func _on_stats_tab_open_button_pressed() -> void:
	stats_tab.show()
	stats_tab_open_button.hide()


func _on_stats_tab_hidden() -> void:
	stats_tab_open_button.show()
