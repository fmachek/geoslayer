class_name AbilityPickupParticles
extends CPUParticles2D
## Emits particles after an [AbilityPickup] has successfully unlocked
## a new [Ability].


## Starts emitting particles and connects
## [signal finished] to [method queue_free].
func play() -> void:
	emitting = true
	finished.connect(queue_free)
