extends Node2D

## CutsceneSpirits: Renders the 4 reunited family spirits (Corin, Maria, Elena, Victoria)
## gathered in a loving celestial circle around the completed Ancestral Necklace.

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.16, 1.0)
	
	# Celestial golden aura filling the center
	var aura_pulse = 0.85 + 0.15 * sin(_time * 3.0)
	draw_circle(Vector2(640, 470), 180.0, Color(0.98, 0.92, 0.55, 0.12 * aura_pulse))
	draw_circle(Vector2(640, 470), 110.0, Color(0.98, 0.95, 0.75, 0.18 * aura_pulse))
	
	# 1. Corin (Child Ghost) - Left Center (530, 480)
	_draw_simple_ghost(Vector2(530, 480 + sin(_time * 3.5) * 4.0), Color(0.94, 0.96, 1.0), Color(0.40, 0.90, 1.0), ink, 1.0)
	
	# 2. Mama Maria - Left Top (560, 410)
	_draw_simple_ghost(Vector2(560, 410 + sin(_time * 3.0 + 1.0) * 4.0), Color(0.96, 0.94, 0.98), Color(0.45, 0.85, 0.55), ink, 1.2)
	
	# 3. Bunica Elena - Right Top (720, 410)
	_draw_simple_ghost(Vector2(720, 410 + sin(_time * 3.2 + 2.0) * 4.0), Color(0.98, 0.93, 0.96), Color(0.95, 0.40, 0.50), ink, 1.2)
	
	# 4. Străbunica Victoria - Right Center (750, 480)
	_draw_simple_ghost(Vector2(750, 480 + sin(_time * 2.8 + 0.5) * 4.0), Color(0.96, 0.94, 0.98), Color(0.98, 0.85, 0.35), ink, 1.3)
	
	# Rising golden spirit motes / stardust particles
	for i in range(12):
		var t = fmod(_time * 0.35 + float(i) / 12.0, 1.0)
		var px = 640.0 + sin(i * 1.7) * 140.0
		var py = 560.0 - t * 240.0
		var p_alpha = sin(t * PI)
		draw_rect(Rect2(px - 2, py - 2, 4, 4), Color(1.0, 0.95, 0.6, p_alpha * 0.8))

func _draw_simple_ghost(pos: Vector2, sheet_col: Color, aura_col: Color, ink: Color, sc: float) -> void:
	# Subtle aura
	draw_circle(pos - Vector2(0, 16 * sc), 22.0 * sc, Color(aura_col.r, aura_col.g, aura_col.b, 0.25))
	
	# Ghost sheet body
	var w = 14.0 * sc
	var h = 24.0 * sc
	draw_rect(Rect2(pos.x - w - 2, pos.y - h - 2, w * 2.0 + 4, h + 4), ink)
	draw_rect(Rect2(pos.x - w, pos.y - h, w * 2.0, h), sheet_col)
	
	# Eyes
	draw_rect(Rect2(pos.x - 5 * sc, pos.y - h + 6 * sc, 3 * sc, 4 * sc), ink)
	draw_rect(Rect2(pos.x + 2 * sc, pos.y - h + 6 * sc, 3 * sc, 4 * sc), ink)
	draw_rect(Rect2(pos.x - 4 * sc, pos.y - h + 7 * sc, sc, sc), Color.WHITE)
	draw_rect(Rect2(pos.x + 3 * sc, pos.y - h + 7 * sc, sc, sc), Color.WHITE)
	
	# Cheek blush
	draw_rect(Rect2(pos.x - 7 * sc, pos.y - h + 12 * sc, 3 * sc, 2 * sc), Color(aura_col.r, aura_col.g, aura_col.b, 0.7))
	draw_rect(Rect2(pos.x + 4 * sc, pos.y - h + 12 * sc, 3 * sc, 2 * sc), Color(aura_col.r, aura_col.g, aura_col.b, 0.7))
