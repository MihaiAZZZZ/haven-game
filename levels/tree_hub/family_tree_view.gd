extends Control

## FamilyTreeView: Archival Genealogy Hub for Haven
## Clean retro 16-bit genealogical tree diagram with centered level info modal.

@onready var tree_draw_layer: Control = %TreeDrawLayer
@onready var nodes_container: Control = %NodesContainer
@onready var haven_ascend_button: Button = %HavenAscendButton

# Level Info Popup Modal
@onready var level_popup: Control = %LevelPopup
@onready var popup_backdrop: ColorRect = %PopupBackdrop
@onready var popup_modal: PanelContainer = %PopupModal
@onready var popup_title: Label = %PopupTitle
@onready var popup_subtitle: Label = %PopupSubtitle
@onready var popup_desc: Label = %PopupDesc
@onready var enter_memory_button: Button = %EnterMemoryButton
@onready var close_button: Button = %CloseButton

var _selected_ancestor_id: String = ""
var _time: float = 0.0
var _node_buttons: Dictionary = {}
var _branch_growth_progress: Dictionary = {"corin": 1.0, "mama": 1.0, "bunica": 1.0, "originea": 1.0}

func _ready() -> void:
	if enter_memory_button:
		enter_memory_button.pressed.connect(_on_enter_memory_pressed)
	if haven_ascend_button:
		haven_ascend_button.pressed.connect(_on_haven_ascend_pressed)
	if close_button:
		close_button.pressed.connect(_hide_level_popup)
	if popup_backdrop:
		popup_backdrop.gui_input.connect(_on_backdrop_gui_input)
		
	# Initialize branch progress based on current unlocked state
	for a_id in GameManager.ancestors.keys():
		var a = GameManager.ancestors[a_id]
		_branch_growth_progress[a_id] = 1.0 if a.unlocked else 0.0
		
	_setup_tree_nodes()
	_update_ascension_status()
	
	if not GameManager.last_completed_ancestor_id.is_empty():
		_play_new_branch_unlocked_fx(GameManager.last_completed_ancestor_id)
		GameManager.last_completed_ancestor_id = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if level_popup and level_popup.visible:
			_hide_level_popup()
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	_time += delta
	if tree_draw_layer:
		tree_draw_layer.queue_redraw()

func _setup_tree_nodes() -> void:
	for child in nodes_container.get_children():
		child.queue_free()
	_node_buttons.clear()
		
	for a_id in GameManager.ancestors.keys():
		var a: AncestorData = GameManager.ancestors[a_id]
		
		var btn = Button.new()
		btn.name = "Node_" + a.id
		btn.custom_minimum_size = Vector2(200, 60)
		btn.position = a.tree_position - Vector2(100, 30)
		
		# Clean typography: no brackets, no useless tags
		var display_name = a.name if a.unlocked else "???"
		btn.text = display_name + "\n(" + a.relation + ")"
		
		# Crisp 16-bit rectangular stylebox
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(0)
		style.content_margin_left = 12.0
		style.content_margin_right = 12.0
		style.content_margin_top = 8.0
		style.content_margin_bottom = 8.0
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 3
		style.shadow_size = 0
		
		var style_hover = style.duplicate() as StyleBoxFlat
		var style_pressed = style.duplicate() as StyleBoxFlat
		
		var font_col: Color
		if a.solved:
			style.bg_color = Color(0.14, 0.24, 0.18, 0.96) # Dark forest green
			style.border_color = Color(0.35, 0.72, 0.48, 1.0)
			style_hover.bg_color = Color(0.18, 0.32, 0.23, 1.0)
			style_hover.border_color = Color(0.45, 0.85, 0.58, 1.0)
			style_pressed.bg_color = Color(0.12, 0.20, 0.15, 1.0)
			style_pressed.border_color = style.border_color
			font_col = Color(0.92, 0.96, 0.93, 1.0)
		elif a.unlocked:
			style.bg_color = Color(0.18, 0.16, 0.22, 0.96) # Archival slate
			style.border_color = Color(0.85, 0.68, 0.28, 1.0) # Antique brass gold
			style_hover.bg_color = Color(0.25, 0.22, 0.30, 1.0)
			style_hover.border_color = Color(0.98, 0.82, 0.38, 1.0)
			style_pressed.bg_color = Color(0.15, 0.13, 0.18, 1.0)
			style_pressed.border_color = style.border_color
			font_col = Color(0.98, 0.94, 0.85, 1.0)
		else:
			style.bg_color = Color(0.10, 0.09, 0.12, 0.90) # Muted iron slate
			style.border_color = Color(0.24, 0.22, 0.28, 1.0)
			style_hover.bg_color = Color(0.14, 0.12, 0.17, 0.95)
			style_hover.border_color = Color(0.30, 0.28, 0.35, 1.0)
			style_pressed.bg_color = style.bg_color
			style_pressed.border_color = style.border_color
			font_col = Color(0.48, 0.45, 0.52, 1.0)
			
		btn.focus_mode = Control.FOCUS_NONE
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		btn.add_theme_stylebox_override("disabled", style)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		btn.add_theme_color_override("font_color", font_col)
		btn.add_theme_color_override("font_hover_color", font_col)
		btn.add_theme_color_override("font_pressed_color", font_col)
		btn.add_theme_color_override("font_focus_color", font_col)
		btn.add_theme_font_size_override("font_size", 12)
		
		btn.pressed.connect(func(): _show_level_popup(a.id))
		nodes_container.add_child(btn)
		_node_buttons[a.id] = btn

func _show_level_popup(ancestor_id: String) -> void:
	_selected_ancestor_id = ancestor_id
	AudioSynth.play_click()
	var a: AncestorData = GameManager.get_ancestor(ancestor_id)
	if not a or not level_popup:
		return
		
	if a.unlocked:
		popup_title.text = a.memory_title
		popup_subtitle.text = a.name + " • " + a.relation
		popup_desc.text = a.memory_description
		enter_memory_button.visible = true
		enter_memory_button.disabled = false
		enter_memory_button.text = "Reia Amintirea" if a.solved else "Intră în Amintire"
	else:
		popup_title.text = "Amintire Încuiată"
		popup_subtitle.text = "??? • " + a.relation
		popup_desc.text = "Vindecă amintirea anterioară pentru a debloca această ramură din arbore."
		enter_memory_button.visible = true
		enter_memory_button.disabled = true
		enter_memory_button.text = "Amintire Blocată"
		
	level_popup.visible = true
	popup_modal.scale = Vector2(0.9, 0.9)
	popup_modal.modulate.a = 0.0
	
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(popup_modal, "scale", Vector2.ONE, 0.25)
	tw.tween_property(popup_modal, "modulate:a", 1.0, 0.18)

func _hide_level_popup() -> void:
	if not level_popup or not level_popup.visible:
		return
	AudioSynth.play_click()
	var tw = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_property(popup_modal, "scale", Vector2(0.95, 0.95), 0.12)
	tw.tween_property(popup_modal, "modulate:a", 0.0, 0.12)
	tw.finished.connect(func():
		if level_popup:
			level_popup.visible = false
	)

func _on_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_hide_level_popup()

func _on_enter_memory_pressed() -> void:
	if _selected_ancestor_id.is_empty():
		return
	var a = GameManager.get_ancestor(_selected_ancestor_id)
	if not a or not a.unlocked:
		return
	AudioSynth.play_chime(1.1)
	GameManager.go_to_memory(_selected_ancestor_id)

func _update_ascension_status() -> void:
	if GameManager.are_all_memories_solved():
		haven_ascend_button.visible = true
		haven_ascend_button.text = "URCĂ ÎN HAVEN (ASCENSIUNE)"
		var tw = create_tween().set_loops().set_trans(Tween.TRANS_BACK)
		tw.tween_property(haven_ascend_button, "scale", Vector2(1.04, 1.04), 0.7)
		tw.tween_property(haven_ascend_button, "scale", Vector2.ONE, 0.7)
	else:
		haven_ascend_button.visible = false

func _on_haven_ascend_pressed() -> void:
	AudioSynth.play_ascension()
	GameManager.go_to_ascension()

func _play_new_branch_unlocked_fx(completed_id: String) -> void:
	AudioSynth.play_fanfare()
	var unlocked_target = ""
	if completed_id == "corin" and GameManager.ancestors.has("mama") and GameManager.ancestors["mama"].unlocked:
		unlocked_target = "mama"
	elif completed_id == "mama" and GameManager.ancestors.has("bunica") and GameManager.ancestors["bunica"].unlocked:
		unlocked_target = "bunica"
	elif completed_id == "bunica" and GameManager.ancestors.has("originea") and GameManager.ancestors["originea"].unlocked:
		unlocked_target = "originea"
		
	if not unlocked_target.is_empty():
		_branch_growth_progress[unlocked_target] = 0.0
		var tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_method(func(val: float):
			_branch_growth_progress[unlocked_target] = val
		, 0.0, 1.0, 1.5)

func draw_family_tree(canvas: Control) -> void:
	if not canvas:
		return
		
	var dark_ink = Color(0.06, 0.05, 0.08, 1.0)
	var frame_border = Color(0.24, 0.22, 0.28, 0.45)
	
	# 1. Archival manuscript frame & corner ticks
	canvas.draw_rect(Rect2(24, 24, 1232, 672), frame_border, false, 1.0)
	_draw_corner_mark(canvas, Vector2(24, 24), 8.0, frame_border)
	_draw_corner_mark(canvas, Vector2(1256, 24), 8.0, frame_border)
	_draw_corner_mark(canvas, Vector2(24, 696), 8.0, frame_border)
	_draw_corner_mark(canvas, Vector2(1256, 696), 8.0, frame_border)
	
	# 2. Genealogy Flowchart Connectors (Matching user's exact hand-drawn sketch)
	# Top Box (Corin): Center (640, 160) -> Bottom connection at (640, 190)
	# Left Box (Mama): Center (380, 310) -> Right edge connection at (480, 310)
	# Right Box (Bunica): Center (900, 310) -> Left edge at (800, 310), Bottom edge at (900, 340)
	# Orthogonal T-Junction center at (640, 310)
	# Origin Box (Străbunica Victoria): Center (640, 480) -> Right edge connection at (740, 480)
	
	var corin_bot = Vector2(640, 190)
	var junction_center = Vector2(640, 310)
	var mama_right = Vector2(480, 310)
	var bunica_left = Vector2(800, 310)
	var bunica_bot = Vector2(900, 340)
	var origin_corner = Vector2(900, 480)
	var origin_right = Vector2(740, 480)
	
	var corin_data: AncestorData = GameManager.ancestors.get("corin", null)
	var mama_data: AncestorData = GameManager.ancestors.get("mama", null)
	var bunica_data: AncestorData = GameManager.ancestors.get("bunica", null)
	var originea_data: AncestorData = GameManager.ancestors.get("originea", null)
	
	var col_stem = Color(0.85, 0.68, 0.28, 1.0)
	var col_mama = _get_branch_color(mama_data)
	var col_bunica = _get_branch_color(bunica_data)
	var col_originea = _get_branch_color(originea_data)
	
	var growth_mama = _branch_growth_progress.get("mama", 1.0 if (mama_data and mama_data.unlocked) else 0.0)
	var growth_bunica = _branch_growth_progress.get("bunica", 1.0 if (bunica_data and bunica_data.unlocked) else 0.0)
	var growth_originea = _branch_growth_progress.get("originea", 1.0 if (originea_data and originea_data.unlocked) else 0.0)
	
	var is_active_stem = true
	var is_active_mama = mama_data != null and mama_data.unlocked
	var is_active_bunica = bunica_data != null and bunica_data.unlocked
	var is_active_originea = originea_data != null and originea_data.unlocked
	
	# Draw Orthogonal Genealogy Lines (4px dark ink under-stroke, 2px pulsing animated core)
	# A. Vertical Stem from Corin down directly to T-Junction center
	_draw_ortho_line(canvas, corin_bot, junction_center, dark_ink, col_stem, is_active_stem, 1.0)
	
	# B. Horizontal Bar left directly to Mama's right edge
	_draw_ortho_line(canvas, junction_center, mama_right, dark_ink, col_mama, is_active_mama, growth_mama)
	
	# C. Horizontal Bar right directly to Bunica's left edge
	_draw_ortho_line(canvas, junction_center, bunica_left, dark_ink, col_bunica, is_active_bunica, growth_bunica)
	
	# D. Descending Branch from Bunica to Originea (Străbunica Victoria)
	if is_active_originea or (bunica_data and bunica_data.solved):
		var mid_growth = clamp(growth_originea * 2.0, 0.0, 1.0)
		var horiz_growth = clamp((growth_originea - 0.5) * 2.0, 0.0, 1.0)
		_draw_ortho_line(canvas, bunica_bot, origin_corner, dark_ink, col_originea, is_active_originea, mid_growth)
		if mid_growth >= 0.95:
			_draw_ortho_line(canvas, origin_corner, origin_right, dark_ink, col_originea, is_active_originea, horiz_growth)
	
	# E. Junction Node Markers
	# Center T-Junction node
	canvas.draw_rect(Rect2(junction_center.x - 3, junction_center.y - 3, 6, 6), dark_ink)
	canvas.draw_rect(Rect2(junction_center.x - 2, junction_center.y - 2, 4, 4), col_stem)
	
	# Mama right edge joint
	if growth_mama >= 0.95:
		canvas.draw_rect(Rect2(mama_right.x - 3, mama_right.y - 3, 6, 6), dark_ink)
		canvas.draw_rect(Rect2(mama_right.x - 2, mama_right.y - 2, 4, 4), col_mama)
	
	# Bunica left edge joint
	if growth_bunica >= 0.95:
		canvas.draw_rect(Rect2(bunica_left.x - 3, bunica_left.y - 3, 6, 6), dark_ink)
		canvas.draw_rect(Rect2(bunica_left.x - 2, bunica_left.y - 2, 4, 4), col_bunica)
		
	# Originea right edge joint
	if growth_originea >= 0.95:
		canvas.draw_rect(Rect2(origin_right.x - 3, origin_right.y - 3, 6, 6), dark_ink)
		canvas.draw_rect(Rect2(origin_right.x - 2, origin_right.y - 2, 4, 4), col_originea)
	
	# 3. Selected Node Highlight
	if not _selected_ancestor_id.is_empty() and GameManager.ancestors.has(_selected_ancestor_id):
		var sel_a: AncestorData = GameManager.ancestors[_selected_ancestor_id]
		var sel_rect = Rect2(sel_a.tree_position - Vector2(103, 33), Vector2(206, 66))
		canvas.draw_rect(sel_rect, Color(0.96, 0.82, 0.35, 0.9), false, 2.0)

func _get_branch_color(a: AncestorData) -> Color:
	if not a:
		return Color(0.24, 0.22, 0.28, 0.6)
	if a.solved:
		return Color(0.38, 0.78, 0.52, 1.0)
	elif a.unlocked:
		return Color(0.85, 0.68, 0.28, 1.0)
	else:
		return Color(0.22, 0.20, 0.26, 0.6)

func _draw_ortho_line(canvas: Control, from: Vector2, to: Vector2, ink_col: Color, line_col: Color, is_active: bool = true, growth: float = 1.0) -> void:
	if growth <= 0.01:
		return
	var actual_to = from.lerp(to, growth)
	
	canvas.draw_line(from, actual_to, ink_col, 4.0)
	
	var pulse = 0.85 + 0.15 * sin(_time * 4.0) if is_active else 1.0
	var core_col = Color(line_col.r * pulse, line_col.g * pulse, line_col.b * pulse, line_col.a)
	canvas.draw_line(from, actual_to, core_col, 2.0)
	
	if is_active and growth >= 0.2:
		var spark_count = 3
		for i in range(spark_count):
			var t = fmod(_time * 0.45 + float(i) / float(spark_count), 1.0)
			if t <= growth:
				var spark_pos = from.lerp(to, t)
				var spark_col = Color(1.0, 1.0, 0.9, 0.95)
				canvas.draw_rect(Rect2(spark_pos.x - 2, spark_pos.y - 2, 4, 4), ink_col)
				canvas.draw_rect(Rect2(spark_pos.x - 1, spark_pos.y - 1, 2, 2), spark_col)

func _draw_corner_mark(canvas: Control, pos: Vector2, size: float, col: Color) -> void:
	canvas.draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), col, 1.0)
	canvas.draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), col, 1.0)
