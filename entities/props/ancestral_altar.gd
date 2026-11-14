extends Area2D
class_name AncestralAltar

## AncestralAltar: The sacred altar where the 3 fragments of the Ancestral Necklace
## are placed to assemble the unified artifact, shatter the curse of love, and open Haven.

signal piece_placed(index: int, piece_name: String)
signal puzzle_completed()

var is_active: bool = false
var pieces_placed: Array[bool] = [false, false, false]
var _player_in_range: bool = false
var _time: float = 0.0

const PIECE_NAMES = [
	"Piesa 1: Baza cu Lant (Corin)",
	"Piesa 2: Amuleta Mamei (Maria)",
	"Piesa 3: Medalionul cu Rubin (Elena)"
]

const PIECE_COLORS = [
	Color(0.98, 0.82, 0.28), # Gold
	Color(0.40, 0.85, 0.55), # Emerald/Gold Cameo
	Color(0.95, 0.28, 0.38)  # Ruby
]

@onready var prompt_container: Node2D = %PromptContainer
@onready var prompt_label: Label = %PromptLabel
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if prompt_container:
		prompt_container.visible = false
	_update_prompt()

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func activate_altar() -> void:
	is_active = true
	AudioSynth.play_chime(1.2)
	_update_prompt()
	if _player_in_range and prompt_container:
		prompt_container.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or not is_active:
		return
		
	if event.is_action_pressed("interact") and not event.is_echo():
		_place_next_piece()
		get_viewport().set_input_as_handled()

func _place_next_piece() -> void:
	# Find next unplaced piece
	var next_idx = -1
	for i in range(3):
		if not pieces_placed[i]:
			next_idx = i
			break
			
	if next_idx == -1:
		return # Already all placed
		
	pieces_placed[next_idx] = true
	
	# Harmonic pitch for each piece (C, E, G chord progression)
	var pitches = [1.0, 1.25, 1.5]
	AudioSynth.play_chime(pitches[next_idx])
	AudioSynth.play_sfx("switch", 1.0)
	
	piece_placed.emit(next_idx, PIECE_NAMES[next_idx])
	_update_prompt()
	
	# Check if all pieces placed
	if pieces_placed[0] and pieces_placed[1] and pieces_placed[2]:
		_on_all_pieces_placed()

func _on_all_pieces_placed() -> void:
	is_active = false
	if prompt_container:
		prompt_container.visible = false
	AudioSynth.play_fanfare()
	puzzle_completed.emit()

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_in_range = true
		if is_active and prompt_container:
			prompt_container.visible = true
			prompt_container.scale = Vector2.ZERO
			var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(prompt_container, "scale", Vector2.ONE, 0.2)

func _on_body_exited(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_in_range = false
		if prompt_container:
			prompt_container.visible = false

func _update_prompt() -> void:
	if not prompt_label or not status_label:
		return
		
	var placed_count = 0
	for p in pieces_placed:
		if p: placed_count += 1
		
	status_label.text = "Piese Asamblate: " + str(placed_count) + "/3"
	
	if not is_active:
		prompt_label.text = "Vorbeste mai intai cu Strabunica Victoria"
	elif placed_count < 3:
		prompt_label.text = "[E] Asaza " + PIECE_NAMES[placed_count]
	else:
		prompt_label.text = "Colierul este Intreg!"

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var stone_dark = Color(0.24, 0.22, 0.28, 1.0)
	var stone_mid = Color(0.36, 0.34, 0.42, 1.0)
	var stone_light = Color(0.48, 0.46, 0.56, 1.0)
	var gold = Color(0.96, 0.82, 0.35, 1.0)
	
	# Altar dimensions (centered at 0, sitting on ground y = 0)
	var altar_w = 220.0
	var altar_h = 48.0
	var half_w = altar_w * 0.5
	
	# Stepped stone base
	draw_rect(Rect2(-half_w - 6, -altar_h - 2, altar_w + 12, altar_h + 4), ink)
	draw_rect(Rect2(-half_w - 4, -altar_h, altar_w + 8, altar_h), stone_dark)
	draw_rect(Rect2(-half_w, -altar_h + 4, altar_w, altar_h - 8), stone_mid)
	draw_rect(Rect2(-half_w + 4, -altar_h + 4, altar_w - 8, 4), stone_light)
	
	# Ancient Runic Inscriptions glowing on altar face
	var rune_alpha = 0.4 + 0.3 * sin(_time * 3.0) if is_active else 0.2
	for i in range(5):
		var rx = -half_w + 24.0 + i * 40.0
		draw_rect(Rect2(rx, -24, 6, 10), Color(gold.r, gold.g, gold.b, rune_alpha))
		draw_rect(Rect2(rx - 2, -20, 10, 2), Color(gold.r, gold.g, gold.b, rune_alpha))
		
	# 3 Pedestal Sockets on top of Altar (Left: -65, Center: 0, Right: +65)
	var socket_positions = [Vector2(-65, -altar_h - 8), Vector2(0, -altar_h - 8), Vector2(65, -altar_h - 8)]
	
	for i in range(3):
		var spos = socket_positions[i]
		var is_placed = pieces_placed[i]
		var col = PIECE_COLORS[i]
		
		# Pedestal cup
		draw_rect(Rect2(spos.x - 18, spos.y - 4, 36, 12), ink)
		draw_rect(Rect2(spos.x - 16, spos.y - 2, 32, 8), stone_mid)
		
		if is_placed:
			# Placed piece glowing intensely
			var pulse = 0.85 + 0.15 * sin(_time * 4.0 + i)
			draw_circle(spos + Vector2(0, -12), 16.0, Color(col.r, col.g, col.b, 0.28 * pulse))
			
			# Vertical beam connecting socket upward
			draw_rect(Rect2(spos.x - 2, spos.y - 60, 4, 52), Color(col.r, col.g, col.b, 0.35 * pulse))
			
			# The specific piece art
			match i:
				0: # Baza cu Lant (Corin)
					draw_rect(Rect2(spos.x - 8, spos.y - 18, 16, 12), ink)
					draw_rect(Rect2(spos.x - 6, spos.y - 16, 12, 8), gold)
					draw_rect(Rect2(spos.x - 2, spos.y - 14, 4, 4), Color.WHITE)
				1: # Amuleta Mamei (Maria)
					draw_rect(Rect2(spos.x - 9, spos.y - 20, 18, 16), ink)
					draw_rect(Rect2(spos.x - 7, spos.y - 18, 14, 12), col)
					draw_rect(Rect2(spos.x - 4, spos.y - 15, 8, 6), Color.WHITE)
				2: # Rubinul Bunicii (Elena)
					draw_rect(Rect2(spos.x - 10, spos.y - 22, 20, 18), ink)
					draw_rect(Rect2(spos.x - 8, spos.y - 20, 16, 14), col)
					draw_rect(Rect2(spos.x - 3, spos.y - 17, 6, 8), Color(1.0, 0.7, 0.8))
		else:
			# Empty socket: dashed/faint outline
			draw_rect(Rect2(spos.x - 10, spos.y - 14, 20, 12), ink, false, 2.0)
			if is_active:
				# Pulsing invitation glow
				var glow_a = 0.2 + 0.2 * sin(_time * 4.0 + i * 1.5)
				draw_rect(Rect2(spos.x - 8, spos.y - 12, 16, 8), Color(col.r, col.g, col.b, glow_a))
				
	# If all 3 pieces are assembled: The Unified Ancestral Necklace floats above the center!
	if pieces_placed[0] and pieces_placed[1] and pieces_placed[2]:
		var nex_pos = Vector2(0, -altar_h - 48.0 + sin(_time * 3.0) * 3.0)
		_draw_unified_necklace(nex_pos, ink, gold)

func _draw_unified_necklace(pos: Vector2, ink: Color, gold: Color) -> void:
	# Divine radiant aura
	var aura_r = 34.0 + 4.0 * sin(_time * 5.0)
	draw_circle(pos, aura_r, Color(0.98, 0.92, 0.45, 0.32))
	draw_circle(pos, aura_r * 0.6, Color(1.0, 1.0, 0.85, 0.55))
	
	# Sweeping golden chain loops
	for link in range(-4, 5):
		var lx = pos.x + link * 6
		var ly = pos.y - 14 + abs(link) * 3
		draw_rect(Rect2(lx - 2, ly - 2, 4, 4), ink)
		draw_rect(Rect2(lx - 1, ly - 1, 2, 2), gold)
		
	# Center Cameo Casing (Mama)
	draw_rect(Rect2(pos.x - 10, pos.y - 4, 20, 16), ink)
	draw_rect(Rect2(pos.x - 8, pos.y - 2, 16, 12), gold)
	
	# Large glowing Faceted Ruby Medallion (Elena)
	draw_rect(Rect2(pos.x - 6, pos.y, 12, 10), Color(0.95, 0.25, 0.35))
	draw_rect(Rect2(pos.x - 2, pos.y + 2, 4, 4), Color.WHITE)
	
	# Sparkling celestial cross-stars
	var stars = [Vector2(-24, -10), Vector2(24, -10), Vector2(0, -32), Vector2(-16, 18), Vector2(16, 18)]
	for st in stars:
		var st_pulse = 0.5 + 0.5 * sin(_time * 6.0 + st.x)
		if st_pulse > 0.4:
			draw_rect(Rect2(pos.x + st.x - 2, pos.y + st.y - 2, 4, 4), Color.WHITE)
