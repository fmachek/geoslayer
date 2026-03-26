class_name Slower
extends Enemy
## Represents an [Enemy] spawned by [Boss1].
## It uses the [Slowshot] [Ability].


func _load_abilities() -> void:
	_load_ability(Slowshot.new())


## Overridden empty method to ensure that the drop pool
## is empty.
func generate_drop_pool() -> void:
	pass
