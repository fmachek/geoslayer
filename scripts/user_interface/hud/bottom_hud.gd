class_name BottomHUD
extends MarginContainer

@onready var stats_tab: StatsTab = %StatsTab
@onready var stats_tab_open_button: Button = %StatsTabOpenButton
@onready var hud_hide_button: Button = %HUDHideButton

@onready var ability_container: HBoxContainer = $VBoxContainer/AbilityItemContainer
@onready var level_hud: HBoxContainer = $VBoxContainer/LevelHUD

@onready var small_hud: SmallHUD = %SmallHUD


func _ready() -> void:
	var collapse_hud: bool = ConfigManager.collapse_hud
	if collapse_hud:
		hud_hide_button.text = "Expand HUD"
		level_hud.hide()
		ability_container.hide()
		small_hud.show()


func _on_stats_tab_open_button_pressed() -> void:
	stats_tab.show()
	stats_tab_open_button.hide()


func _on_stats_tab_hidden() -> void:
	stats_tab_open_button.show()


func _on_hud_hide_button_pressed() -> void:
	if ability_container.visible and level_hud.visible:
		ConfigManager.update_collapse_hud(true)
		hud_hide_button.text = "Expand HUD"
		ability_container.hide()
		level_hud.hide()
		small_hud.show()
	else:
		ConfigManager.update_collapse_hud(false)
		hud_hide_button.text = "Collapse HUD"
		ability_container.show()
		level_hud.show()
		small_hud.hide()
