extends Area2D
class_name InteractiveDrawer

## InteractiveDrawer: Antique furniture piece searchable by the ghost player.
## Contains atmospheric clues or the hidden Ancestral Necklace.

signal drawer_searched(drawer: InteractiveDrawer, found_necklace: bool)
signal key_found(drawer: InteractiveDrawer, key_id: String)

@export var drawer_name: String = "Comoda Veche"
@export var search_dialog_text: String = "Doar arcuri vechi de ceas si praf..."
@export var contains_necklace: bool = false
@export var contains_key: bool = false
@export var key_id: String = ""
@export var is_locked: bool = false
@export var locked_dialog_text: String = "Este încuiat! Ai nevoie de cheie!"
@export_enum("dresser", "wardrobe", "desk", "clock_cabinet") var furniture_type: String = "dresser"
@export var furniture_size: Vector2 = Vector2(72, 64)

var is_searched: bool = false
var _player_in_range: bool = false
var _slide_offset: float = 0.0

@onready var prompt_container: Node2D = %PromptContainer
@onready var prompt_label: Label = %PromptLabel
@onready var message_container: Node2D = %MessageContainer
@onready var message_label: Label = %MessageLabel

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player on layer 2
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if prompt_container:
		prompt_container.visible = false
	if message_container:
		message_container.visible = false
		message_container.modulate.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		search_drawer()
		get_viewport().set_input_as_handled()

func search_drawer() -> void:
	if is_locked:
		AudioSynth.play_click()
		_show_message(locked_dialog_text)
		return
		
	if is_searched:
		# If already searched, show the message again briefly
		_show_message(search_dialog_text)
		return
		
	is_searched = true
	AudioSynth.play_sfx("switch", 0.85)
	
	if contains_key:
		key_found.emit(self, key_id)
		_spawn_key_popup()
		
	# Animate drawer sliding open / doors popping open
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_slide_offset", 10.0, 0.25)
	
	# Show message toast
	_show_message(search_dialog_text)
	
	drawer_searched.emit(self, contains_necklace)
	queue_redraw()

func unlock() -> void:
	is_locked = false
	AudioSynth.play_chime(1.3)
	if prompt_label:
		prompt_label.text = "[E] Deschide"

func _show_message(text_to_show: String) -> void:
	if not message_container or not message_label:
		return
		
	message_label.text = text_to_show
	message_container.visible = true
	message_container.position.y = -furniture_size.y - 10.0
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(message_container, "position:y", -furniture_size.y - 28.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(message_container, "modulate:a", 1.0, 0.2)
	
	# Fade out after reading time
	var close_tw = create_tween()
	close_tw.tween_interval(3.2)
	close_tw.tween_property(message_container, "modulate:a", 0.0, 0.5)
	close_tw.tween_callback(func(): message_container.visible = false)

func _on_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_in_range = true
		if prompt_container:
			prompt_container.visible = true
			prompt_label.text = "[E] Cauta" if not is_searched else "[E] Deschide"
			prompt_container.scale = Vector2.ZERO
			var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(prompt_container, "scale", Vector2.ONE, 0.2)

func _on_body_exited(body: Node2D) -> void:
	if body is GhostPlayer:
		_player_in_range = false
		if prompt_container:
			prompt_container.visible = false

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	var wood_dark = Color(0.38, 0.24, 0.16, 1.0)
	var wood_mid = Color(0.52, 0.35, 0.22, 1.0)
	var wood_light = Color(0.66, 0.46, 0.30, 1.0)
	var brass = Color(0.95, 0.78, 0.28, 1.0)
	
	var w = furniture_size.x
	var h = furniture_size.y
	var half_w = w * 0.5
	
	# Base position is centered horizontally, sitting on floor (y: -h to 0)
	var box_rect = Rect2(-half_w, -h, w, h)
	
	match furniture_type:
		"dresser":
			# 3-drawer antique commode
			# Outer casing
			draw_rect(Rect2(-half_w - 2, -h - 2, w + 4, h + 4), ink)
			draw_rect(box_rect, wood_dark)
			draw_rect(Rect2(-half_w + 2, -h + 2, w - 4, h - 4), wood_mid)
			
			# Carved feet
			draw_rect(Rect2(-half_w + 4, 0, 8, 4), ink)
			draw_rect(Rect2(half_w - 12, 0, 8, 4), ink)
			
			# 3 Drawers
			var drawer_h = (h - 8) / 3.0
			for i in range(3):
				var dy = -h + 4.0 + i * drawer_h
				var pull_x = _slide_offset if (is_searched and i == 1) else 0.0
				
				# Drawer front
				draw_rect(Rect2(-half_w + 4 + pull_x, dy, w - 8, drawer_h - 2), ink)
				draw_rect(Rect2(-half_w + 5 + pull_x, dy + 1, w - 10, drawer_h - 4), wood_light if pull_x == 0.0 else Color(0.25, 0.16, 0.12))
				
				# Brass handle
				var handle_x = pull_x
				var handle_y = dy + drawer_h * 0.5 - 1.0
				draw_rect(Rect2(handle_x - 6, handle_y - 2, 12, 4), ink)
				draw_rect(Rect2(handle_x - 5, handle_y - 1, 10, 2), brass)
				
		"wardrobe":
			# Tall 2-door armoire
			draw_rect(Rect2(-half_w - 2, -h - 4, w + 4, h + 6), ink)
			# Crown molding
			draw_rect(Rect2(-half_w - 4, -h - 4, w + 8, 6), ink)
			draw_rect(Rect2(-half_w - 3, -h - 3, w + 6, 4), wood_light)
			# Main body
			draw_rect(box_rect, wood_dark)
			
			# Left & Right doors
			var door_w = (w - 6) * 0.5
			var door_open = _slide_offset * 0.6 if is_searched else 0.0
			
			# Left door
			draw_rect(Rect2(-half_w + 2 - door_open, -h + 4, door_w, h - 8), ink)
			draw_rect(Rect2(-half_w + 3 - door_open, -h + 5, door_w - 2, h - 10), wood_mid)
			
			# Right door
			draw_rect(Rect2(1 + door_open, -h + 4, door_w, h - 8), ink)
			draw_rect(Rect2(2 + door_open, -h + 5, door_w - 2, h - 10), wood_mid)
			
			# Keyholes & handles
			draw_rect(Rect2(-3 - door_open, -h * 0.5 - 2, 2, 6), brass)
			draw_rect(Rect2(3 + door_open, -h * 0.5 - 2, 2, 6), brass)
			
		"desk":
			# Watchmaker desk
			draw_rect(Rect2(-half_w - 2, -h - 2, w + 4, 8), ink)
			draw_rect(Rect2(-half_w, -h, w, 6), wood_light)
			
			# Desk legs
			draw_rect(Rect2(-half_w + 2, -h + 6, 8, h - 6), ink)
			draw_rect(Rect2(-half_w + 3, -h + 6, 6, h - 6), wood_dark)
			draw_rect(Rect2(half_w - 10, -h + 6, 8, h - 6), ink)
			draw_rect(Rect2(half_w - 9, -h + 6, 6, h - 6), wood_dark)
			
			# Center drawer
			var pull_y = _slide_offset * 0.5 if is_searched else 0.0
			draw_rect(Rect2(-half_w + 12, -h + 6 + pull_y, w - 24, 18), ink)
			draw_rect(Rect2(-half_w + 13, -h + 7 + pull_y, w - 26, 16), wood_mid)
			draw_rect(Rect2(-4, -h + 14 + pull_y, 8, 3), brass)
			
		"clock_cabinet":
			# Tall Grandfather Clock base cabinet
			draw_rect(Rect2(-half_w - 2, -h - 2, w + 4, h + 4), ink)
			draw_rect(box_rect, wood_dark)
			draw_rect(Rect2(-half_w + 3, -h + 3, w - 6, h - 6), wood_mid)
			
			# Brass pendulum visible inside glass window
			draw_rect(Rect2(-half_w + 8, -h + 8, w - 16, h - 16), ink)
			draw_rect(Rect2(-half_w + 9, -h + 9, w - 18, h - 18), Color(0.18, 0.12, 0.22))
			# Pendulum rod & bob
			draw_rect(Rect2(-1, -h + 9, 2, h - 26), brass)
			draw_rect(Rect2(-6, -20, 12, 10), brass)
			
			# If searched: golden glow if necklace, or open panel
			if is_searched:
				draw_rect(Rect2(-half_w + 4, -h + 4, 4, h - 8), brass)

func _spawn_key_popup() -> void:
	AudioSynth.play_fanfare()
	
	var popup_node = Node2D.new()
	popup_node.name = "KeyPopupVisual"
	popup_node.z_index = 50
	popup_node.position = Vector2(0, -furniture_size.y * 0.5)
	popup_node.scale = Vector2.ZERO
	add_child(popup_node)
	
	# Key drawing helper
	var key_drawer = Node2D.new()
	key_drawer.draw.connect(func():
		var ink = Color(0.12, 0.09, 0.16, 1.0)
		var gold = Color(0.98, 0.82, 0.28, 1.0)
		var bright = Color(1.0, 0.96, 0.7, 1.0)
		
		# Golden halo
		key_drawer.draw_circle(Vector2.ZERO, 16.0, Color(0.98, 0.82, 0.28, 0.35))
		
		# Round top loop of key
		key_drawer.draw_rect(Rect2(-8, -14, 16, 12), ink)
		key_drawer.draw_rect(Rect2(-6, -12, 12, 8), gold)
		key_drawer.draw_rect(Rect2(-2, -10, 4, 4), ink) # Hole
		
		# Shaft
		key_drawer.draw_rect(Rect2(-3, -2, 6, 22), ink)
		key_drawer.draw_rect(Rect2(-2, -1, 4, 20), gold)
		key_drawer.draw_rect(Rect2(-1, 0, 2, 18), bright)
		
		# Teeth
		key_drawer.draw_rect(Rect2(3, 10, 6, 4), ink)
		key_drawer.draw_rect(Rect2(2, 11, 6, 2), gold)
		key_drawer.draw_rect(Rect2(3, 16, 8, 4), ink)
		key_drawer.draw_rect(Rect2(2, 17, 8, 2), gold)
		
		# Sparkle diamonds around key
		var sparkles = [Vector2(-18, -12), Vector2(18, -8), Vector2(-14, 16), Vector2(16, 20)]
		for sp in sparkles:
			key_drawer.draw_rect(Rect2(sp.x - 2, sp.y - 2, 4, 4), ink)
			key_drawer.draw_rect(Rect2(sp.x - 1, sp.y - 1, 2, 2), bright)
	)
	popup_node.add_child(key_drawer)
	
	# Floating Title Label
	var key_lbl = Label.new()
	key_lbl.text = "[ CHEIA DE ALAMĂ ]"
	key_lbl.position = Vector2(-75, -34)
	key_lbl.custom_minimum_size = Vector2(150, 20)
	key_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_lbl.add_theme_color_override("font_color", Color(0.98, 0.88, 0.35, 1.0))
	key_lbl.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.16, 1.0))
	key_lbl.add_theme_constant_override("outline_size", 4)
	key_lbl.add_theme_font_size_override("font_size", 11)
	popup_node.add_child(key_lbl)
	
	# Prominent Rising Animation
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(popup_node, "position:y", -furniture_size.y - 52.0, 0.65)
	tw.tween_property(popup_node, "scale", Vector2(1.3, 1.3), 0.65)
	
	# Gentle hover bobbing after rising
	tw.chain().tween_callback(func():
		var bob_tw = create_tween().set_loops()
		bob_tw.tween_property(popup_node, "position:y", -furniture_size.y - 58.0, 0.7).set_trans(Tween.TRANS_SINE)
		bob_tw.tween_property(popup_node, "position:y", -furniture_size.y - 48.0, 0.7).set_trans(Tween.TRANS_SINE)
	)
