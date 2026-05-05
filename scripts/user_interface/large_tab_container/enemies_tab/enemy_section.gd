class_name EnemySection
extends HBoxContainer
## Represents a section in he [EnemiesTab] which displays information about
## an [Enemy].

@onready var _texture_rect: TextureRect = $EnemyIcon
@onready var _name_label: Label = $VBoxContainer/NameLabel
@onready var _desc_label: Label = $VBoxContainer/DescriptionLabel


## Name of the [Enemy] whose information is being displayed.
var enemy_name: String
## Description explaining what the [Enemy] does.
var description: String
## Path leading to the [Enemy]'s icon.
var texture_path: String


func _ready() -> void:
	_name_label.text = enemy_name
	_desc_label.text = description
	var texture: Texture2D = load(texture_path)
	_texture_rect.texture = texture


## Loads information about an [Enemy] with a given [param new_enemy_name].
func load_enemy(new_enemy_name: String, new_enemy_description: String) -> void:
	self.enemy_name = new_enemy_name
	self.description = new_enemy_description
	self.texture_path = TextureManager.get_enemy_icon_path(new_enemy_name)


## Loads information about [Shooter].
func load_shooter() -> void:
	var desc := "Fires one projectile directly at its target and sometimes \
			two smaller projectiles in different directions."
	load_enemy("Shooter", desc)


## Loads information about [Sprayer].
func load_sprayer() -> void:
	var desc := "Fires a wave of projectiles which deal damage up front and over time. \
			If it gets too close to its target, it explodes into similar projectiles."
	load_enemy("Sprayer", desc)


## Loads information about [Guard].
func load_guard() -> void:
	var desc := "Fires a projectile directly at the target and two smaller projectiles \
			around it. Also uses a shield which blocks incoming projectiles."
	load_enemy("Guard", desc)


## Loads information about [Healer].
func load_healer() -> void:
	var desc := "Casts Lifesteal and heals friendly units around itself."
	load_enemy("Healer", desc)
