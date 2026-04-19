class_name Mage
extends Enemy
## Represents an enemy who casts [Shoot] and [Teleport] with a longer cooldown.
## When it dies, it spawns a [GrowingDamagingZone] at its position.

const _ZONE_SCENE := preload(
		"res://scenes/objects/zones/growing_damaging_zone.tscn")

## Final radius of the [GrowingDamagingZone].
@export var zone_final_radius: float = 300.0
## Lifetime of the [GrowingDamagingZone].
@export var zone_life_time: float = 15.0
## Base damage dealt by the [GrowingDamagingZone].
@export var zone_base_damage: int = 30
## Time between [GrowingDamagingZone] damage ticks.
@export var zone_tick_time: float = 0.5


func _ready() -> void:
	super()
	died.connect(spawn_growing_zone)


func _load_abilities() -> void:
	var teleport: Teleport = Teleport.new()
	teleport.cooldown *= 1.5
	_load_ability(teleport)
	_load_ability(Shoot.new())


## Spawns a [GrowingDamagingZone] at [member global_position].
func spawn_growing_zone():
	var zone: GrowingDamagingZone = _ZONE_SCENE.instantiate()
	zone.caster = self
	zone.radius = zone_final_radius
	zone.base_damage = zone_base_damage
	zone.time_per_tick = zone_tick_time
	zone.life_time = zone_life_time
	zone.global_position = global_position
	get_parent().add_child(zone)
