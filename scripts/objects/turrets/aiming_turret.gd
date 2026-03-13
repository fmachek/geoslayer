class_name AimingTurret
extends Turret

var is_aiming: bool = false
var aim_target: Node2D

func _ready() -> void:
	super()
	PlayerManager.player_spawned.connect(_on_player_spawned)
	started_shooting.connect(func(): is_aiming = true)
	stopped_shooting.connect(func(): is_aiming = false)

func _process(delta: float) -> void:
	if is_aiming:
		look_at(aim_target.global_position)
		rotation += deg_to_rad(90)

func _on_player_spawned(player: PlayerCharacter) -> void:
	aim_target = player
