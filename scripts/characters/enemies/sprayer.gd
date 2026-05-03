class_name Sprayer
extends Enemy
## Represents an [Enemy] who casts [Spray] and explodes into [DoTProjectile]s
## when it gets close to its target.

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/dot_projectile.tscn")

## Damage dealt by [DoTProjectile]s fired when exploding.
var proj_damage: int = 5
## Travel speed of [DoTProjectile]s fired when exploding.
var proj_speed: float = 3.0
## Variety in the travel speed of [DoTProjectile]s fired when exploding.
var proj_speed_variety: float = 0.5
## Radius of [DoTProjectile]s fired when exploding.
var proj_radius: int = 8
## Amount of [DoTProjectile]s fired when exploding.
var proj_amount: int = 40
## Damage dealt by [DamageOverTime] applied by [DoTProjectile]s
## fired when exploding.
var dot_damage: int = 1
## Time between damage ticks of [DamageOverTime] applied by
## [DoTProjectile]s fired when exploding.
var dot_tick_time: float = 1.0
## Total amount of damage ticks of [DamageOverTime] applied by
## [DoTProjectile]s fired when exploding.
var dot_tick_amount: int = 5


func _init() -> void:
	# Set lower stop distance than default
	stop_distance = 120.0


func _ready() -> void:
	super()
	target_reached.connect(explode) # Explodes when it gets close


func _load_abilities() -> void:
	_load_ability(Spray.new())


## Explodes into many [DoTProjectile]s and dies.
func explode() -> void:
	drop_pool.clear()
	var angle: float = 0.0
	for i in range(proj_amount):
		angle = i * (TAU / proj_amount)
		var direction := Vector2.from_angle(angle)
		_fire_projectile(direction)
	die()


func _fire_projectile(direction: Vector2) -> void:
	var speed_variety: float = randf_range(-proj_speed_variety, proj_speed_variety)
	var final_speed: float = proj_speed + speed_variety
	var props := ProjectileProperties.new(
			draw_color, outline_color, direction, final_speed,
			self, proj_damage, proj_radius, global_position
	)
	var proj: DoTProjectile = ProjectileFunctions.fire_projectile(_PROJ_SCENE, props)
	var dot := DamageOverTime.new(dot_damage, dot_tick_time, dot_tick_amount)
	proj.dot = dot
