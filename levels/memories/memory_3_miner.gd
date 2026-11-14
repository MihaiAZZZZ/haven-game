extends MemoryBase

## Level 2: Elena - Bunica
## Amintirea 2: Depozitul din WW2 (WWII Military Depot Stealth Parkour)
## Goal: Retrieve the 3rd Necklace Piece before the 40s countdown runs out!
## Avoid sweeping searchlights: entering the light in physical mode trips the alarm!
## In ghost mode (Phased), Corin is an ethereal wisp and slips through undetected!

@onready var timer_label: Label = %TimerLabel
@onready var alert_label: Label = %AlertLabel
@onready var alert_container: Control = %AlertContainer
@onready var searchlight_left: Area2D = %SearchlightLeft
@onready var searchlight_mid: Area2D = %SearchlightMid
@onready var searchlight_right: Area2D = %SearchlightRight

var time_limit: float = 35.0
var time_remaining: float = 35.0
var is_alarm_active: bool = false
var is_won: bool = false
var _last_tick_sec: int = -1

func _setup_memory() -> void:
	ancestor_id = "bunica"
	memory_title = "Amintirea 2: Depozitul din WW2 (Elena)"
	initial_objective = "Recupereaza Piesa 3 din Colier in 35s! Evita proiectoarele si patrulele!"
	time_remaining = time_limit
	
	if alert_container:
		alert_container.visible = false
		
	if searchlight_left:
		searchlight_left.player_detected.connect(_on_searchlight_detected)
	if searchlight_mid:
		searchlight_mid.player_detected.connect(_on_searchlight_detected)
	if searchlight_right:
		searchlight_right.player_detected.connect(_on_searchlight_detected)
		
	# Connect Ground Soldier patrols
	for child in get_children():
		if child is WW2PatrolSoldier or child.has_signal("player_detected"):
			if child != searchlight_left and child != searchlight_mid and child != searchlight_right:
				child.player_detected.connect(_on_soldier_detected)
		
	if relic:
		relic.relic_type = MemoryPickup.RelicType.NECKLACE_GEM
		relic.relic_name = "Piesa 3 din Colier: Medalionul cu Rubin"
		relic.relic_color = Color(0.95, 0.28, 0.38) # Ruby red

func _process(delta: float) -> void:
	if is_won or is_alarm_active:
		return
		
	time_remaining -= delta
	_update_timer_display()
	
	if time_remaining <= 0.0:
		time_remaining = 0.0
		_on_alarm_triggered("TIMPUL A EXPIRAT! Patrula a sosit!")

func _update_timer_display() -> void:
	if not timer_label:
		return
		
	var seconds = int(ceil(time_remaining))
	timer_label.text = "TIMP: %02ds" % seconds
	
	if time_remaining <= 10.0:
		# Pulsing red urgency
		var flash = int(time_remaining * 4.0) % 2 == 0
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25) if flash else Color(1.0, 0.9, 0.3))
		if seconds != _last_tick_sec:
			_last_tick_sec = seconds
			AudioSynth.play_tick()
	else:
		timer_label.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78))

func _on_searchlight_detected() -> void:
	if is_won or is_alarm_active:
		return
	_on_alarm_triggered("ALARMA! Reperat de proiector!")

func _on_soldier_detected() -> void:
	if is_won or is_alarm_active:
		return
	_on_alarm_triggered("ALARMA! Patrula de soldati te-a descoperit!")

func _on_alarm_triggered(reason: String) -> void:
	if is_alarm_active:
		return
	is_alarm_active = true
	AudioSynth.play_alarm()
	
	# Alert and panic all soldiers and searchlights simultaneously
	for child in get_children():
		if child is WW2PatrolSoldier:
			child.panic()
		elif child is SweepingSearchlight:
			child._is_alerted = true
			
	# Freeze player during alarm restart
	if player:
		player.velocity = Vector2.ZERO
		player.set_physics_process(false)
	
	if alert_container and alert_label:
		alert_label.text = reason + "\nSe reia nivelul..."
		alert_container.visible = true
		
	var tw = create_tween().set_parallel(true)
	if alert_container:
		alert_container.modulate.a = 0.0
		tw.tween_property(alert_container, "modulate:a", 1.0, 0.15)
		
	var restart_timer = get_tree().create_timer(1.3)
	restart_timer.timeout.connect(func():
		get_tree().reload_current_scene()
	)

func _on_relic_collected() -> void:
	is_won = true
	AudioSynth.play_fanfare()
	if complete_dialog:
		complete_dialog.show_completion(ancestor_id)
