class_name Turret
extends Node2D

@onready var col_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var muzzle: Node2D = $Muzzle
@onready var shoot_timer: Timer = $ShootTimer

@export var draw_color: Color = Color("#8f6e6e")
@export var outline_color: Color = Color("664b4bff")

@export var damage: int = 5
@export var projectile_speed: int = 2
@export var projectile_radius: int = 10

func _draw():
	var width = $Area2D/CollisionShape2D.shape.size.x
	var height = $Area2D/CollisionShape2D.shape.size.y
	draw_rect(Rect2(-width/2, -height/2, width, height), draw_color)
	draw_rect(Rect2(-width/2, -height/2, width, height), outline_color, false, 4)

func _ready() -> void:
	WorldManager.wave_started.connect(start_shooting)
	WorldManager.wave_ended.connect(stop_shooting)

func start_shooting() -> void:
	shoot_timer.start()

func stop_shooting() -> void:
	shoot_timer.stop()

func shoot() -> void:
	var proj_direction: Vector2 = (muzzle.global_position - global_position).normalized()
	var proj_props := ProjectileProperties.new(draw_color, outline_color, proj_direction, projectile_speed, self, damage, projectile_radius, global_position)
	var projectile: Projectile = ProjectileFunctions.fire_projectile(proj_props)
