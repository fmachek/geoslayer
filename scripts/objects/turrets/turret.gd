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

## Says if the [Turret] can start shooting or not.
var can_start_shooting: bool = true

#region @onready variables
@onready var _col_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var _muzzle: Node2D = $Muzzle
@onready var _shoot_timer: Timer = $ShootTimer
@onready var _shoot_particles: CPUParticles2D = $ShootParticles
#endregion


func _ready() -> void:
	WorldManager.wave_started.connect(start_shooting)
	WorldManager.wave_ended.connect(stop_shooting)
	WorldManager.final_wave_started.connect(disable)
	_shoot_particles.color = draw_color
	_shoot_timer.wait_time = shoot_time


func _draw() -> void:
	var shape = _col_shape.shape
	var width: float = shape.size.x
	var height: float = shape.size.y
	var outline_width: float = 6.0
	
	var rect_x: float = -width / 2
	var rect_y: float = -height / 2
	var fill_rect := Rect2(rect_x, rect_y, width, height)
	
	var outline_rect_x: float = rect_x + outline_width / 2
	var outline_rect_y: float = rect_y + outline_width / 2
	var outline_rect := Rect2(
			outline_rect_x, outline_rect_y,
			width - outline_width, height - outline_width)
	
	draw_rect(fill_rect, draw_color)
	draw_rect(outline_rect, outline_color, false, outline_width)


## Becomes unable to start shooting.
func disable() -> void:
	can_start_shooting = false


## Makes the [Turret] start shooting. Emits [signal started_shooting].
func start_shooting() -> void:
	if not can_start_shooting:
		return
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


## Multiplies [member damage] by [code]1.2[/code].
func increase_damage() -> void:
	damage *= 1.2
