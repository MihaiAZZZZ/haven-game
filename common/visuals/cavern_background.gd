extends Node2D
class_name CavernBackground

## Retro Pixel Art Grotto Background for Gabriel's level
## Features stepped pixel stalactites, glowing pixel crystal clusters, and pixel minecart rails.

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var ink = Color(0.11, 0.08, 0.13, 1.0)
	var p = 3.0 # Pixel unit
	
	# Deep retro cavern blackberry base
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.18, 0.12, 0.2))
	
	# Horizontal cavern rock stratum lines
	for y in range(0, 720, 40):
		draw_rect(Rect2(0, y, 1280, p), Color(0.14, 0.09, 0.16))
		
	# Stepped Pixel Stalactites (Ceiling)
	var stal_count = 12
	for i in range(stal_count):
		var sx = 20.0 + i * 110.0
		var sh = 40.0 + (i % 4) * 18.0
		_draw_pixel_spike(Vector2(sx, 0), sh, 24.0, true, Color(0.26, 0.18, 0.28), ink, p)
		
	# Stepped Pixel Stalagmites (Floor)
	for i in range(10):
		var gx = 45.0 + i * 125.0
		var gh = 32.0 + (i % 3) * 16.0
		_draw_pixel_spike(Vector2(gx, 720), gh, 20.0, false, Color(0.24, 0.16, 0.26), ink, p)
		
	# Glowing Pixel Crystals
	_draw_pixel_crystal(Vector2(180, 580), Color(0.85, 0.5, 0.65), ink, p)
	_draw_pixel_crystal(Vector2(530, 595), Color(0.92, 0.72, 0.35), ink, p)
	_draw_pixel_crystal(Vector2(880, 310), Color(0.4, 0.88, 0.95), ink, p)
	_draw_pixel_crystal(Vector2(1160, 470), Color(0.85, 0.5, 0.65), ink, p)
	
	# Pixel Minecart Rails
	var rail_y = 618.0
	for x in range(160, 640, 24):
		draw_rect(Rect2(x, rail_y - 2.0, 16.0, 8.0), ink)
		draw_rect(Rect2(x + p, rail_y - 2.0 + p, 16.0 - 2.0 * p, 8.0 - 2.0 * p), Color(0.46, 0.32, 0.2))
	# Iron rails (two 2-pixel lines)
	draw_rect(Rect2(140, rail_y - 4.0, 520, p), ink)
	draw_rect(Rect2(140, rail_y - 4.0 + p, 520, p), Color(0.72, 0.7, 0.75))

func _draw_pixel_spike(base_pos: Vector2, height: float, width: float, pointing_down: bool, body_col: Color, ink: Color, p: float) -> void:
	var steps = int(height / (p * 2.0))
	for i in range(steps):
		var t = float(i) / steps
		var w = lerp(width, p * 2.0, t)
		var y = base_pos.y + (i * p * 2.0 if pointing_down else - (i + 1) * p * 2.0)
		draw_rect(Rect2(base_pos.x - w * 0.5, y, w, p * 2.0), ink)
		draw_rect(Rect2(base_pos.x - w * 0.5 + p, y, w - 2.0 * p, p * 2.0), body_col)

func _draw_pixel_crystal(pos: Vector2, col: Color, ink: Color, p: float) -> void:
	var pulse = 1.0 + 0.05 * sin(_time * 4.0 + pos.x)
	var h = 32.0 * pulse
	# 3 pixel shards
	draw_rect(Rect2(pos.x - 6.0, pos.y - h, 12.0, h), ink)
	draw_rect(Rect2(pos.x - 6.0 + p, pos.y - h + p, 12.0 - 2.0 * p, h - p), col)
	# 1-pixel highlight
	draw_rect(Rect2(pos.x - 6.0 + p, pos.y - h + p, p, h * 0.6), Color.WHITE)
