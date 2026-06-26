class_name Blast
extends Ability

const _ZONE_SCENE := preload(
	"res://scenes/objects/zones/blast_zone.tscn"
)

var life_time: float = 0.2
var final_radius: float = 500.0
var knockback: float = 2000.0
var base_damage: int = 25


func _init() -> void:
	var ability_cooldown: float = 1.5
	var ability_cast_time: float = 0.5
	var ability_description := "Releases a blast which knocks enemies back and deals \
			damage to them."
	super(ability_cooldown, ability_cast_time, ability_description)


func _perform_ability() -> void:
	_spawn_blast_zone()
	finished_casting.emit()


func _handle_casting() -> void:
	pass


func _spawn_blast_zone() -> void:
	var zone: BlastZone = _ZONE_SCENE.instantiate()
	zone.caster = character
	zone.life_time = life_time
	zone.final_radius = final_radius
	zone.knockback = knockback
	zone.base_damage = base_damage
	zone.global_position = character.global_position
	character.get_parent().add_child(zone)
