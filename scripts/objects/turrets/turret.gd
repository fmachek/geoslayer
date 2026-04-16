class_name Turret
extends Node2D
## Represents a turret which sits in place and fires projectiles
## in the direction it is facing.

## Emitted when the [Turret] fires a [Projectile].
signal shot()
## Emitted when the [Turret] starts shooting.
signal started_shooting()
## Emitted when the [Turret] stops shooting.
signal stopped_shooting()

const _PROJ_SCENE := preload("res://scenes/objects/projectiles/projectile.tscn")

#region @export variables
## Fill color of the [Turret] shape and its [Muzzle].
@export var draw_color: Color = Color("#8f6e6e")
## Outline color of the [Turret] shape and its [Muzzle].
@export var outline_color: Color = Color("664b4bff")
## Damage dealt by every [Projectile] fired by the [Turret].
@export var damage: int = 5
## Speed at which every [Projectile] fired by the [Turret] travels.
@export var projectile_speed: int = 2
## Radius of every [Projectile] fired by the [Turret].
@export var projectile_radius: int = 10
## Amount of time between individual shots.
@export var shoot_time: float = 3.0
## Knockback applied by [Projectile]s fired.
@export var projectile_knockback: float = 0.0
#endregion

#region @onready variables
@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _muzzle: Node2D = $Muzzle
@onready var _shoot_timer: Timer = $ShootTimer
@onready var _shoot_particles: CPUParticles2D = $ShootParticles
#endregion


func _ready() -> void:
	WorldManager.wave_started.connect(start_shooting)
	WorldManager.wave_ended.connect(stop_shooting)
	_shoot_particles.color = draw_color
	_shoot_timer.wait_time = shoot_time


func _draw() -> void:
	var shape = $Area2D/CollisionShape2D.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var rect := Rect2(-width / 2, -height / 2, width, height)
	draw_rect(rect, draw_color)
	draw_rect(rect, outline_color, false, 4)


## Makes the [Turret] start shooting. Emits [signal started_shooting].
func start_shooting() -> void:
	_shoot_timer.start()
	started_shooting.emit()


## Makes the [Turret] stop shooting. Emits [signal stopped_shooting].
func stop_shooting() -> void:
	_shoot_timer.stop()
	stopped_shooting.emit()


## Fires a [Projectile] in the direction of the [Muzzle].
func shoot() -> void:
	shot.emit()
	var proj_direction: Vector2 = (_muzzle.global_position - global_position).normalized()
	var proj_props := ProjectileProperties.new(
			draw_color, outline_color, proj_direction, projectile_speed,
			self, damage, projectile_radius, global_position)
	var projectile := ProjectileFunctions.fire_projectile(_PROJ_SCENE, proj_props)
	projectile.knockback = projectile_knockback
	_shoot_particles.emitting = true
