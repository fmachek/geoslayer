class_name AimingTurret
extends Turret
## Represents a type of turret which aims at the player.

var _is_aiming: bool = false
var _aim_target: Node2D


func _ready() -> void:
	super()
	PlayerManager.player_spawned.connect(_on_player_spawned)
	started_shooting.connect(func(): _is_aiming = true)
	stopped_shooting.connect(func(): _is_aiming = false)


func _process(_delta: float) -> void:
	if _is_aiming and _aim_target:
		look_at(_aim_target.global_position)
		rotation += deg_to_rad(90) # Offset because look_at uses +X axis


func _on_player_spawned(player: PlayerCharacter) -> void:
	_aim_target = player
	player.died.connect(_on_player_died.bind(player))


func _on_player_died(player: PlayerCharacter) -> void:
	if player.died.is_connected(_on_player_died.bind(player)):
		player.died.disconnect(_on_player_died.bind(player))
	_aim_target = null
