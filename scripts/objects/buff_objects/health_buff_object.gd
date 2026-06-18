class_name HealthBuffObject
extends BuffObject


func _ready() -> void:
	super()
	was_picked_up.connect(heal_player)


func heal_player(player: PlayerCharacter) -> void:
	var health: Health = player.health
	if health:
		var max_health: int = health.max_value_after_buffs
		player.heal(max_health)
