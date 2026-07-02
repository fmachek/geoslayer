class_name DodgeUIElement
extends HBoxContainer

@onready var _name_label: Label = %AbilityNameLabel
@onready var _desc_label: Label = %DescriptionLabel
@onready var _texture_rect: TextureRect = %AbilityTextureRect


func load_dodge(ability: Dodge):
	_name_label.text = ability.get_ability_name()
	_texture_rect.texture = ability.texture
	_desc_label.text = ability.description
	_update_cooldown_label(ability.cooldown)
	_update_cast_time_label(ability.cast_time)


func _update_cooldown_label(cooldown: float) -> void:
	var new_text: String = "Cooldown: " + str(cooldown)
	if cooldown <= 1.0:
		new_text += " second"
	else:
		new_text += " seconds"
	%CooldownLabel.text = new_text


func _update_cast_time_label(cast_time: float) -> void:
	if cast_time == 0.0:
		%CastTimeLabel.text = "Cast duration: instant"
		return
	
	var new_text: String = "Cast duration: " + str(cast_time)
	if cast_time <= 1.0:
		new_text += " second"
	else:
		new_text += " seconds"
	%CastTimeLabel.text = new_text
