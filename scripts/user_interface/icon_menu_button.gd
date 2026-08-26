class_name IconMenuButton
extends Button

@onready var icon_margin_container: MarginContainer = get_node("IconMarginContainer")
@onready var icon_rect: TextureRect = icon_margin_container.get_node("TextureRect")


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	icon_rect.modulate = get_theme_color("font_color")


func _on_mouse_entered() -> void:
	icon_rect.modulate = get_theme_color("font_hover_color")


func _on_mouse_exited() -> void:
	icon_rect.modulate = get_theme_color("font_color")
