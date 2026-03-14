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
	if is_aiming and aim_target:
		look_at(aim_target.global_position)
		rotation += deg_to_rad(90)

func _on_player_spawned(player: PlayerCharacter) -> void:
	aim_target = player
	player.died.connect(_on_player_died.bind(player))

func _on_player_died(player: PlayerCharacter) -> void:
	if player.died.is_connected(_on_player_died.bind(player)):
		player.died.disconnect(_on_player_died.bind(player))
	aim_target = null
