extends Node2D
class_name OriginSanctuaryBackground

## Retro Pixel Art Background for Level 3: Sanctuarul Originii (Străbunica Victoria)
## Features Gothic stone arches, glowing stained-glass rose window depicting the ancestral tree,
## candlelight sconces with animated flames, and atmospheric mystical rays.

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var ink = Color(0.10, 0.08, 0.14, 1.0)
	var p = 3.0 # Pixel unit
	
	# Deep sanctuary midnight stone background
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.14, 0.12, 0.18))
	
	# Horizontal stone masonry blocks
	for y in range(0, 720, 48):
		draw_rect(Rect2(0, y, 1280, p), Color(0.10, 0.08, 0.13))
		draw_rect(Rect2(0, y + p, 1280, p), Color(0.18, 0.15, 0.23))
		
	# Vertical mortar joints staggered
	for row in range(0, int(720 / 48)):
		var y = row * 48
		var offset_x = (row % 2) * 64
		for x in range(offset_x, 1280, 128):
			draw_rect(Rect2(x, y, p, 48), Color(0.10, 0.08, 0.13))
			
	# Gothic Cathedral Arches (Left & Right)
	_draw_gothic_arch(Vector2(200, 0), Vector2(160, 650), ink, Color(0.18, 0.15, 0.22), p)
	_draw_gothic_arch(Vector2(1080, 0), Vector2(160, 650), ink, Color(0.18, 0.15, 0.22), p)
	
	# Magnificent Central Stained Glass Rose Window (Center at 640, 220, radius 130px)
	var win_center = Vector2(640, 220)
	var win_r = 130.0
	
	# Outer stone frame
	_draw_stepped_circle(win_center, win_r + 8.0, ink, p)
	_draw_stepped_circle(win_center, win_r, Color(0.24, 0.20, 0.32), p)
	
	# Stained glass petal facets (Jewel tones: Gold, Amethyst, Ruby, Sapphire, Emerald)
	var petals = 8
	var facet_colors = [
		Color(0.85, 0.68, 0.28, 0.85), # Gold (Corin)
		Color(0.35, 0.72, 0.55, 0.85), # Emerald (Mama)
		Color(0.85, 0.30, 0.45, 0.85), # Ruby (Bunica)
		Color(0.55, 0.38, 0.85, 0.85), # Amethyst (Victoria)
	]
	for i in range(petals):
		var a1 = (float(i) / petals) * TAU + _time * 0.05
		var a2 = (float(i + 1) / petals) * TAU + _time * 0.05
		var col = facet_colors[i % facet_colors.size()]
		var pulse = 0.85 + 0.15 * sin(_time * 2.5 + i)
		col = Color(col.r * pulse, col.g * pulse, col.b * pulse, col.a)
		
		var p1 = win_center + Vector2(cos(a1), sin(a1)) * (win_r - 12.0)
		var p2 = win_center + Vector2(cos(a2), sin(a2)) * (win_r - 12.0)
		var pts = PackedVector2Array([win_center, p1, p2])
		draw_colored_polygon(pts, col)
		draw_line(win_center, p1, ink, 3.0)
		
	# Window center medallion (Ancestral Tree silhouette)
	_draw_stepped_circle(win_center, 38.0, ink, p)
	_draw_stepped_circle(win_center, 32.0, Color(0.98, 0.88, 0.45), p)
	# Tree trunk silhouette
	draw_rect(Rect2(win_center.x - 3, win_center.y - 12, 6, 24), ink)
	draw_rect(Rect2(win_center.x - 14, win_center.y - 16, 28, 10), ink)
	draw_rect(Rect2(win_center.x - 10, win_center.y - 24, 20, 10), ink)
	
	# Ethereal celestial light shafts streaming down from window
	for ray in range(4):
		var ray_angle = -0.4 + ray * 0.28
		var ray_alpha = 0.08 + 0.04 * sin(_time * 1.8 + ray)
		var ray_pts = PackedVector2Array([
			win_center + Vector2(-20 + ray * 10, 20),
			win_center + Vector2(20 + ray * 10, 20),
			win_center + Vector2(cos(ray_angle) * 600.0, 520),
			win_center + Vector2(cos(ray_angle) * 600.0 - 80, 520)
		])
		draw_colored_polygon(ray_pts, Color(0.98, 0.92, 0.65, ray_alpha))
		
	# Candlelight Sconces on pillars
	_draw_candle_sconce(Vector2(200, 360), _time, ink, p)
	_draw_candle_sconce(Vector2(1080, 360), _time + 1.2, ink, p)
	_draw_candle_sconce(Vector2(360, 480), _time + 2.1, ink, p)
	_draw_candle_sconce(Vector2(920, 480), _time + 0.7, ink, p)

func _draw_stepped_circle(center: Vector2, radius: float, col: Color, p: float) -> void:
	var steps = 20
	var pts = PackedVector2Array()
	for i in range(steps):
		var a = (float(i) / steps) * TAU
		pts.append(center + Vector2(floor(cos(a) * radius / p) * p, floor(sin(a) * radius / p) * p))
	draw_colored_polygon(pts, col)

func _draw_gothic_arch(center: Vector2, arch_size: Vector2, ink: Color, fill_col: Color, p: float) -> void:
	var half_w = arch_size.x * 0.5
	# Outer stone column lines
	draw_rect(Rect2(center.x - half_w - 6, center.y, 8, arch_size.y), ink)
	draw_rect(Rect2(center.x + half_w - 2, center.y, 8, arch_size.y), ink)
	draw_rect(Rect2(center.x - half_w - 4, center.y, 4, arch_size.y), fill_col)
	draw_rect(Rect2(center.x + half_w, center.y, 4, arch_size.y), fill_col)

func _draw_candle_sconce(pos: Vector2, time_val: float, ink: Color, p: float) -> void:
	# Wrought iron bracket
	draw_rect(Rect2(pos.x - 8, pos.y, 16, 6), ink)
	draw_rect(Rect2(pos.x - 3, pos.y + 6, 6, 12), ink)
	# White wax candle
	draw_rect(Rect2(pos.x - 4, pos.y - 14, 8, 14), ink)
	draw_rect(Rect2(pos.x - 3, pos.y - 13, 6, 12), Color(0.92, 0.90, 0.82))
	# Flickering flame
	var flicker = sin(time_val * 8.0) * 1.5
	var flame_col = Color(0.98, 0.75, 0.2, 1.0)
	var glow_col = Color(0.98, 0.75, 0.2, 0.18 + 0.06 * sin(time_val * 7.0))
	draw_circle(pos + Vector2(0, -18), 16.0, glow_col)
	draw_rect(Rect2(pos.x - 3 + flicker * 0.3, pos.y - 22, 6, 8), ink)
	draw_rect(Rect2(pos.x - 2 + flicker * 0.3, pos.y - 21, 4, 6), flame_col)
	draw_rect(Rect2(pos.x - 1 + flicker * 0.3, pos.y - 19, 2, 3), Color.WHITE)
