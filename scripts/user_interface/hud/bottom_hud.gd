class_name BottomHUD
extends MarginContainer

@onready var stats_tab: StatsTab = $StatsTab
@onready var stats_tab_open_button: Button = $StatsTabOpenButton


func _on_stats_tab_open_button_pressed() -> void:
	stats_tab.show()
	stats_tab_open_button.hide()


func _on_stats_tab_hidden() -> void:
	stats_tab_open_button.show()
