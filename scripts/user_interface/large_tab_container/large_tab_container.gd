class_name LargeTabContainer
extends MarginContainer

@onready var abilities_tab: AbilitiesTab = %AbilitiesTab
@onready var enemies_tab: EnemiesTab = %EnemiesTab

@onready var abilities_tab_open_button: Button = %AbilitiesTabOpenButton
@onready var enemies_tab_open_button: Button = %EnemiesTabOpenButton


func _ready() -> void:
	abilities_tab_open_button.pressed.connect(show_abilities_tab)
	abilities_tab_open_button.pressed.connect(disable_abilities_tab_open_button)
	abilities_tab.hidden.connect(enable_abilities_tab_open_button)
	
	enemies_tab_open_button.pressed.connect(show_enemies_tab)
	enemies_tab_open_button.pressed.connect(disable_enemies_tab_open_button)
	enemies_tab.hidden.connect(enable_enemies_tab_open_button)


func show_abilities_tab() -> void:
	abilities_tab.show()
	enemies_tab.hide() # Hide other tabs


func show_enemies_tab() -> void:
	enemies_tab.show()
	abilities_tab.hide() # Hide other tabs


func enable_abilities_tab_open_button() -> void:
	_enable_open_button(abilities_tab_open_button)


func disable_abilities_tab_open_button() -> void:
	_disable_open_button(abilities_tab_open_button)


func enable_enemies_tab_open_button() -> void:
	_enable_open_button(enemies_tab_open_button)


func disable_enemies_tab_open_button() -> void:
	_disable_open_button(enemies_tab_open_button)


func _enable_open_button(button: Button) -> void:
	button.disabled = false
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _disable_open_button(button: Button) -> void:
	button.disabled = true
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW
