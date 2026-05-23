class_name BossHealthContainer
extends VBoxContainer


@onready var bar: ProgressBar = get_node("ProgressBar")
@onready var health_label: Label = bar.get_node("HealthLabel")
@onready var phase_label: Label = get_node("PhaseLabel")


func _ready() -> void:
	WorldManager.boss_spawned.connect(
		func(boss: Character): call_deferred("_on_boss_spawned", boss)
	)
	WorldManager.boss_died.connect(
		func(): call_deferred("_on_boss_died")
	)


func _on_boss_spawned(boss: Boss) -> void:
	var health: Health = boss.health
	bar.min_value = 0.0
	_update_bar(health)
	
	health.max_value_after_buffs_changed.connect(
		func(old_value, new_value): _update_bar(health)
	)
	health.current_value_changed.connect(
		func(old_value, new_value): _update_bar(health)
	)
	
	boss.phase_changed.connect(_update_phase)
	_update_phase(boss.current_phase)
	
	show()


func _on_boss_died() -> void:
	hide()


func _update_bar(boss_health: Health) -> void:
	bar.max_value = boss_health.max_value_after_buffs
	bar.value = boss_health.current_value
	health_label.text = "%d/%d" % [boss_health.current_value, boss_health.max_value_after_buffs]


func _update_phase(phase: int) -> void:
	phase_label.text = "Phase %d" % phase
