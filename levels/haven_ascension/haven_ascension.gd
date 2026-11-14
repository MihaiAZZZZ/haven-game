extends Control

## HavenAscension: The climatic ascension ending scene in HAVEN (Heaven).
## Clean, cozy, emoji-free narrative.

@onready var message_label: Label = %MessageLabel
@onready var quote_label: Label = %QuoteLabel
@onready var ascend_prompt: Label = %AscendPrompt
@onready var victory_card: PanelContainer = %VictoryCard
@onready var restart_button: Button = %RestartButton
@onready var tree_hub_button: Button = %TreeHubButton

var _time: float = 0.0
var _ascension_started: bool = false
var _ghost_pos: Vector2 = Vector2(640, 500)
var _dialogue_step: int = 0

var _dialogues: Array[Dictionary] = [
	{
		"speaker": "Maria (Mama)",
		"text": "\"Ai adunat toate piesele colierului, dragul meu Corin. Dragostea si amintirile noastre sunt intregi acum.\"",
		"color": Color(0.45, 0.85, 0.55)
	},
	{
		"speaker": "Elena (Bunica)",
		"text": "\"Niciun razboi si nicio durere a trecutului nu a putut invinge familia noastra. Toate legaturile s-au unit!\"",
		"color": Color(0.95, 0.45, 0.65)
	},
	{
		"speaker": "Victoria (Străbunica - Posesorul Originar)",
		"text": "\"Blestemul nascut din iubire este rupt pentru totdeauna. Suntem in sfarsit libere si putem merge in pace spre lumina.\"",
		"color": Color(0.98, 0.85, 0.35)
	},
	{
		"speaker": "Corin (Tu - Sufletul Vindecat)",
		"text": "\"Colierul este complet. Radacinile noastre sunt fericite si libere. Sa mergem acasa, in Rai (Haven)!\"",
		"color": Color(0.4, 0.9, 1.0)
	}
]

func _ready() -> void:
	AudioSynth.play_ascension()
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if tree_hub_button:
		tree_hub_button.pressed.connect(_on_tree_hub_pressed)
		
	_display_current_dialogue()

func _process(delta: float) -> void:
	_time += delta
	
	if _ascension_started:
		_ghost_pos.y -= delta * 140.0
		if _ghost_pos.y < 120.0 and victory_card and not victory_card.visible:
			_show_final_victory()
	else:
		_ghost_pos.y = 500.0 + sin(_time * 2.8) * 10.0
		
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not _ascension_started:
		if event.is_action_pressed("interact") or event.is_action_pressed("jump"):
			_advance_dialogue()

func _advance_dialogue() -> void:
	_dialogue_step += 1
	if _dialogue_step < _dialogues.size():
		AudioSynth.play_chime(1.0 + _dialogue_step * 0.15)
		_display_current_dialogue()
	else:
		_start_ascension_flight()

func _display_current_dialogue() -> void:
	var d = _dialogues[_dialogue_step]
	if message_label:
		message_label.text = d["speaker"]
		message_label.modulate = d["color"]
	if quote_label:
		quote_label.text = d["text"]
	if ascend_prompt:
		ascend_prompt.text = "[Space / Enter] Continua dialogul (" + str(_dialogue_step + 1) + "/" + str(_dialogues.size()) + ")"

func _start_ascension_flight() -> void:
	_ascension_started = true
	AudioSynth.play_ascension()
	if message_label:
		message_label.text = "INALTARE IN HAVEN"
		message_label.modulate = Color(0.95, 0.8, 0.35)
	if quote_label:
		quote_label.text = "Spiritele neamului tau se unesc in lumina calda a Haven-ului..."
	if ascend_prompt:
		ascend_prompt.visible = false

func _show_final_victory() -> void:
	if victory_card:
		victory_card.visible = true
		victory_card.scale = Vector2(0.85, 0.85)
		victory_card.modulate.a = 0.0
		var tw = create_tween().set_parallel(true).set_ignore_time_scale(true)
		tw.tween_property(victory_card, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(victory_card, "modulate:a", 1.0, 0.3)

func _on_restart_pressed() -> void:
	AudioSynth.play_click()
	for a_id in GameManager.ancestors.keys():
		var a = GameManager.ancestors[a_id]
		if a_id == "corin":
			a.unlocked = true
			a.solved = false
		else:
			a.unlocked = false
			a.solved = false
	GameManager.go_to_tree_hub()

func _on_tree_hub_pressed() -> void:
	AudioSynth.play_click()
	GameManager.go_to_tree_hub()

func _draw() -> void:
	var ink = Color(0.14, 0.1, 0.16, 1.0)
	
	# Warm celestial light rays
	var center = Vector2(640, -40)
	var ray_count = 14
	for i in range(ray_count):
		var a = (float(i) / ray_count) * PI + (_time * 0.06)
		var ray_dir = Vector2(cos(a), sin(a))
		var ray_pts = PackedVector2Array([
			center,
			center + ray_dir * 1200.0 + Vector2(-60, 0),
			center + ray_dir * 1200.0 + Vector2(60, 0)
		])
		var alpha = (sin(_time * 1.8 + i) * 0.5 + 0.5) * 0.07 + 0.03
		draw_colored_polygon(ray_pts, Color(0.98, 0.94, 0.75, alpha))
		
	# Warm Portal Gate at the top
	var portal_center = Vector2(640, 90)
	var p_pulse = 1.0 + 0.08 * sin(_time * 3.5)
	draw_circle(portal_center, 90.0 * p_pulse, Color(0.98, 0.88, 0.5, 0.3))
	draw_circle(portal_center, 65.0 * p_pulse, Color(0.98, 0.94, 0.78, 0.5))
	draw_circle(portal_center, 40.0, Color.WHITE)
	
	# Cloud steps
	for step in range(6):
		var sy = 560.0 - step * 70.0
		var sw = 280.0 - step * 25.0
		draw_rect(Rect2(640 - sw * 0.5, sy, sw, 14), Color(0.95, 0.92, 0.85, 0.45))
		
	# Ancestor wisps
	_draw_ancestor_wisp(Vector2(380, _ghost_pos.y + 35 + sin(_time * 2.5) * 8.0), Color(0.45, 0.85, 0.55), "Maria", ink)
	_draw_ancestor_wisp(Vector2(900, _ghost_pos.y + 35 + sin(_time * 2.7 + 1.0) * 8.0), Color(0.95, 0.45, 0.65), "Elena", ink)
	_draw_ancestor_wisp(Vector2(640, _ghost_pos.y - 75 + sin(_time * 2.3 + 2.0) * 8.0), Color(0.98, 0.85, 0.35), "Victoria", ink)
	
	_draw_ascended_corin(_ghost_pos, ink)

func _draw_ancestor_wisp(pos: Vector2, col: Color, name_str: String, ink: Color) -> void:
	var pulse = 1.0 + 0.1 * sin(_time * 4.5 + pos.x)
	var r = 14.0 * pulse
	# Stepped diamond pixel wisp
	var halo_pts = PackedVector2Array([
		Vector2(pos.x, pos.y - r - 6),
		Vector2(pos.x + r + 6, pos.y),
		Vector2(pos.x, pos.y + r + 6),
		Vector2(pos.x - r - 6, pos.y)
	])
	draw_colored_polygon(halo_pts, Color(col.r, col.g, col.b, 0.3))
	draw_rect(Rect2(pos.x - 12, pos.y - 12, 24, 24), ink)
	draw_rect(Rect2(pos.x - 10, pos.y - 10, 20, 20), col)
	draw_rect(Rect2(pos.x - 5, pos.y - 5, 10, 10), Color.WHITE)
	draw_string(ThemeDB.fallback_font, pos + Vector2(-22, 28), name_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, ink)

func _draw_ascended_corin(pos: Vector2, ink: Color) -> void:
	# Pixel halo
	var halo_y = pos.y - 48.0
	draw_rect(Rect2(pos.x - 14, halo_y - 4, 28, 8), ink)
	draw_rect(Rect2(pos.x - 12, halo_y - 2, 24, 4), Color(0.98, 0.85, 0.35))
	draw_rect(Rect2(pos.x - 8, halo_y - 1, 16, 2), Color.WHITE)
	
	# Pixel Wings
	var wing_flap = int(sin(_time * 7.0) * 3.0) * 2
	# Left pixel wing
	draw_rect(Rect2(pos.x - 38, pos.y - 30 + wing_flap, 26, 16), ink)
	draw_rect(Rect2(pos.x - 36, pos.y - 28 + wing_flap, 22, 12), Color(0.98, 0.95, 0.85))
	# Right pixel wing
	draw_rect(Rect2(pos.x + 12, pos.y - 30 + wing_flap, 26, 16), ink)
	draw_rect(Rect2(pos.x + 14, pos.y - 28 + wing_flap, 22, 12), Color(0.98, 0.95, 0.85))
	
	# Pixel Body
	draw_rect(Rect2(pos.x - 18, pos.y - 34, 36, 36), ink)
	draw_rect(Rect2(pos.x - 15, pos.y - 31, 30, 30), Color(0.98, 0.96, 0.92))
	# Happy curved closed pixel eyes ^^
	draw_rect(Rect2(pos.x - 9, pos.y - 20, 5, 3), ink)
	draw_rect(Rect2(pos.x + 4, pos.y - 20, 5, 3), ink)
