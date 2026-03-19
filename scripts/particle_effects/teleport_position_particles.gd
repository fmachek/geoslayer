class_name TeleportPositionParticles
extends CPUParticles2D


func _on_finished() -> void:
	queue_free()


func connect_to_ability(ability: Teleport) -> void:
	ability.finished_casting.connect(func(): emitting = false)
