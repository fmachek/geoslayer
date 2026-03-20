class_name TeleportCastParticles
extends CPUParticles2D


func _on_finished() -> void:
	queue_free()


func connect_to_ability(ability: Ability) -> void:
	ability.finished_casting.connect(func(): emitting = false)
