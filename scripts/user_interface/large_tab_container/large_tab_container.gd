class_name LargeTabContainer
extends MarginContainer

@onready var abilities_tab: AbilitiesTab = %AbilitiesTab
@onready var enemies_tab: EnemiesTab = %EnemiesTab

@onready var abilities_tab_open_button: Button = %AbilitiesTabOpenButton
@onready var enemies_tab_open_button: Button = %EnemiesTabOpenButton

var normal_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/regular_button_normal.tres"
)
var hover_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/regular_button_hover.tres"
)
var pressed_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/regular_button_pressed.tres"
)
var disabled_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/regular_button_disabled.tres"
)
var selected_normal_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/selected/selected_regular_button_normal.tres"
)
var selected_hover_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/selected/selected_regular_button_hover.tres"
)
var selected_pressed_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/selected/selected_regular_button_normal.tres"
)
var selected_disabled_stylebox: StyleBoxFlat = preload(
	"res://assets/user_interface/styles/regular_button/selected/selected_regular_button_disabled.tres"
)


func _ready() -> void:
	abilities_tab_open_button.pressed.connect(_on_abilities_tab_open_button_pressed)
	abilities_tab.hidden.connect(deselect_abilities_tab_open_button)
	
	enemies_tab_open_button.pressed.connect(_on_enemies_tab_open_button_pressed)
	enemies_tab.hidden.connect(deselect_enemies_tab_open_button)


func show_abilities_tab() -> void:
	abilities_tab.show()
	enemies_tab.hide() # Hide other tabs


func show_enemies_tab() -> void:
	enemies_tab.show()
	abilities_tab.hide() # Hide other tabs


func deselect_abilities_tab_open_button() -> void:
	_set_button_regular_stylebox(abilities_tab_open_button)


func select_abilities_tab_open_button() -> void:
	_set_button_selected_stylebox(abilities_tab_open_button)


func deselect_enemies_tab_open_button() -> void:
	_set_button_regular_stylebox(enemies_tab_open_button)


func select_enemies_tab_open_button() -> void:
	_set_button_selected_stylebox(enemies_tab_open_button)


func _set_button_selected_stylebox(button: Button) -> void:
	button.add_theme_stylebox_override("normal", selected_normal_stylebox)
	button.add_theme_stylebox_override("normal_mirrored", selected_normal_stylebox)
	button.add_theme_stylebox_override("pressed", selected_pressed_stylebox)
	button.add_theme_stylebox_override("pressed_mirrored", selected_pressed_stylebox)
	button.add_theme_stylebox_override("hover", selected_hover_stylebox)
	button.add_theme_stylebox_override("hover_mirrored", selected_hover_stylebox)
	button.add_theme_stylebox_override("hover_pressed", selected_pressed_stylebox)
	button.add_theme_stylebox_override("hover_pressed_mirrored", selected_pressed_stylebox)
	button.add_theme_stylebox_override("disabled", selected_disabled_stylebox)
	button.add_theme_stylebox_override("disabled_mirrored", selected_disabled_stylebox)
	button.add_theme_stylebox_override("focus", selected_hover_stylebox)


func _set_button_regular_stylebox(button: Button) -> void:
	button.add_theme_stylebox_override("normal", normal_stylebox)
	button.add_theme_stylebox_override("normal_mirrored", normal_stylebox)
	button.add_theme_stylebox_override("pressed", pressed_stylebox)
	button.add_theme_stylebox_override("pressed_mirrored", pressed_stylebox)
	button.add_theme_stylebox_override("hover", hover_stylebox)
	button.add_theme_stylebox_override("hover_mirrored", hover_stylebox)
	button.add_theme_stylebox_override("hover_pressed", pressed_stylebox)
	button.add_theme_stylebox_override("hover_pressed_mirrored", pressed_stylebox)
	button.add_theme_stylebox_override("disabled", disabled_stylebox)
	button.add_theme_stylebox_override("disabled_mirrored", disabled_stylebox)
	button.add_theme_stylebox_override("focus", hover_stylebox)


func _on_abilities_tab_open_button_pressed() -> void:
	if (abilities_tab.visible):
		abilities_tab.hide()
		deselect_abilities_tab_open_button()
	else:
		show_abilities_tab()
		select_abilities_tab_open_button()


func _on_enemies_tab_open_button_pressed() -> void:
	if (enemies_tab.visible):
		enemies_tab.hide()
		deselect_enemies_tab_open_button()
	else:
		show_enemies_tab()
		select_enemies_tab_open_button()
