extends Node2D
class_name StormBackground

## Retro Pixel Art Maritime Background for Elena's Lighthouse level
## Features stepped pixel clouds, a pixel lighthouse silhouette, and stepped pixel waves.

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var ink = Color(0.09, 0.11, 0.16, 1.0)
	var p = 3.0 # Pixel scale
	
	# Retro twilight navy base
	draw_rect(Rect2(0, 0, 1280, 720), Color(0.14, 0.18, 0.25))
	
	# Horizontal sky dither banding
	for y in range(0, 400, 32):
		var band_col = Color(0.14 + y * 0.0002, 0.18 + y * 0.0002, 0.25 + y * 0.0003)
		draw_rect(Rect2(0, y, 1280, 32), band_col)
		
	# Stepped Pixel Clouds
	for i in range(4):
		var cx = fmod(_time * (18.0 + i * 6.0) + i * 320.0, 1500.0) - 150.0
		var cy = 60.0 + sin(i * 1.5) * 20.0
		var cw = 110.0 + (i % 2) * 30.0
		var ch = 38.0
		var cloud_col = Color(0.22, 0.28, 0.38)
		# Stepped cloud boxes
		draw_rect(Rect2(cx, cy, cw, ch), ink)
		draw_rect(Rect2(cx + p, cy + p, cw - 2.0 * p, ch - 2.0 * p), cloud_col)
		draw_rect(Rect2(cx + 20.0, cy - 14.0, cw - 40.0, 16.0), ink)
		draw_rect(Rect2(cx + 20.0 + p, cy - 14.0 + p, cw - 40.0 - 2.0 * p, 16.0 - p), cloud_col)
		
	# Lighthouse Silhouette on Bluff
	var lh_x = 1080.0
	var lh_y = 190.0
	
	# Rocky stepped bluff
	var rock_pts = PackedVector2Array([
		Vector2(lh_x - 90, 520),
		Vector2(1280, 520),
		Vector2(1280, 290),
		Vector2(lh_x - 30, 290),
		Vector2(lh_x - 60, 380)
	])
	draw_colored_polygon(rock_pts, Color(0.1, 0.12, 0.18))
	draw_polyline(rock_pts, ink, 3.0)
	
	# Pixel Tower (stepped brick red and cream bands)
	draw_rect(Rect2(lh_x - 22, lh_y, 44, 100), Color(0.75, 0.26, 0.3)) # Red brick
	draw_rect(Rect2(lh_x - 22, lh_y + 25, 44, 25), Color(0.92, 0.9, 0.82)) # Cream band
	draw_rect(Rect2(lh_x - 22, lh_y + 75, 44, 25), Color(0.92, 0.9, 0.82)) # Cream band
	draw_rect(Rect2(lh_x - 22, lh_y, 44, 100), ink, false, 3.0)
	
	# Lantern Room with pixel light
	draw_rect(Rect2(lh_x - 26, lh_y - 28, 52, 28), Color(0.96, 0.85, 0.38)) # Amber glow
	draw_rect(Rect2(lh_x - 26, lh_y - 28, 52, 28), ink, false, 3.0)
	draw_rect(Rect2(lh_x - 30, lh_y - 40, 60, 12), Color(0.65, 0.2, 0.24)) # Roof
	draw_rect(Rect2(lh_x - 30, lh_y - 40, 60, 12), ink, false, 3.0)
	
	# Sweeping Pixel Beacon Beam
	var beam_angle = sin(_time * 1.5) * 0.4 - 0.2
	var beam_len = 450.0
	var beam_pts = PackedVector2Array([
		Vector2(lh_x, lh_y - 14),
		Vector2(lh_x, lh_y - 14) + Vector2(cos(PI + beam_angle - 0.08), sin(beam_angle - 0.08)) * beam_len,
		Vector2(lh_x, lh_y - 14) + Vector2(cos(PI + beam_angle + 0.08), sin(beam_angle + 0.08)) * beam_len
	])
	draw_colored_polygon(beam_pts, Color(0.98, 0.92, 0.6, 0.18))
	
	# Stepped Pixel Waves
	for layer in range(3):
		var wave_col = Color(0.12 + layer * 0.03, 0.18 + layer * 0.04, 0.28 + layer * 0.04)
		var base_y = 648.0 + layer * 24.0
		var step = 32.0
		var x = 0.0
		while x <= 1280.0:
			var wave_bob = int(sin((x * 0.02) + _time * (2.2 + layer * 0.8)) * 3.0) * p
			draw_rect(Rect2(x, base_y + wave_bob, step, 40.0), wave_col)
			# 2-pixel white foam top
			draw_rect(Rect2(x, base_y + wave_bob, step, p), Color(0.88, 0.94, 0.98))
			x += step
