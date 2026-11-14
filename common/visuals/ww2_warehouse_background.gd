extends Node2D
class_name WW2WarehouseBackground

## WW2WarehouseBackground: Atmospheric 16-bit WWII military depot interior.
## Renders weathered brickwork, steel roof trusses, barred high windows,
## and stacked wooden ammo crates.

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var w = 1280.0
	var h = 720.0
	var ink = Color(0.08, 0.07, 0.10, 1.0)
	
	# 1. Base dark brickwork / soot-stained wall
	draw_rect(Rect2(0, 0, w, h), Color(0.14, 0.12, 0.15, 1.0))
	
	# Horizontal brick rows with slight variation
	var row_h = 24.0
	var brick_w = 48.0
	for y in range(0, int(h), int(row_h)):
		var shift = (int(y / row_h) % 2) * (brick_w * 0.5)
		draw_line(Vector2(0, y), Vector2(w, y), Color(0.10, 0.08, 0.12, 0.5), 1.0)
		for x in range(-int(brick_w), int(w + brick_w), int(brick_w)):
			var bx = x + shift
			draw_line(Vector2(bx, y), Vector2(bx, y + row_h), Color(0.10, 0.08, 0.12, 0.4), 1.0)
			
	# 2. High Barred Industrial Windows (WW2 night sky outside)
	var win_y = 60.0
	var win_positions = [200.0, 520.0, 840.0]
	for wx in win_positions:
		# Window frame
		draw_rect(Rect2(wx - 70, win_y, 140, 100), ink)
		# Cold night blue glass
		draw_rect(Rect2(wx - 66, win_y + 4, 132, 92), Color(0.18, 0.22, 0.32, 0.85))
		# Moonbeam tint
		draw_rect(Rect2(wx - 66, win_y + 4, 40, 92), Color(0.28, 0.35, 0.48, 0.35))
		# Iron safety bars
		for i in range(5):
			var bar_x = wx - 50 + i * 25
			draw_line(Vector2(bar_x, win_y + 4), Vector2(bar_x, win_y + 96), ink, 3.0)
		# Horizontal pane crossbar
		draw_line(Vector2(wx - 66, win_y + 50), Vector2(wx + 66, win_y + 50), ink, 3.0)
		
	# 3. Steel Overhead Trusses & Girders
	var girder_y = 40.0
	draw_rect(Rect2(0, girder_y, w, 16), ink)
	draw_rect(Rect2(0, girder_y + 2, w, 12), Color(0.25, 0.24, 0.30))
	# Rivets
	for rx in range(20, int(w), 40):
		draw_rect(Rect2(rx, girder_y + 6, 4, 4), ink)
		
	# Diagonal cross-bracing struts
	for tx in range(0, int(w), 160):
		draw_line(Vector2(tx, girder_y + 16), Vector2(tx + 80, girder_y + 90), ink, 3.0)
		draw_line(Vector2(tx + 80, girder_y + 90), Vector2(tx + 160, girder_y + 16), ink, 3.0)
		
	# Lower truss cord
	draw_rect(Rect2(0, girder_y + 90, w, 10), ink)
	draw_rect(Rect2(0, girder_y + 92, w, 6), Color(0.22, 0.20, 0.26))
	
	# 4. Background Stacked Wooden Ammo Crates (pixel art)
	_draw_bg_crate_stack(Vector2(100, 590), 3, 2, ink)
	_draw_bg_crate_stack(Vector2(580, 590), 2, 2, ink)
	_draw_bg_crate_stack(Vector2(1180, 590), 3, 3, ink)
	
	# 5. Low ground shadow & atmospheric industrial vignette
	draw_rect(Rect2(0, 600, w, 120), Color(0.08, 0.07, 0.10, 0.4))
	draw_rect(Rect2(0, 0, 50, h), Color(0.06, 0.05, 0.08, 0.4))
	draw_rect(Rect2(w - 50, 0, 50, h), Color(0.06, 0.05, 0.08, 0.4))

func _draw_bg_crate_stack(pos: Vector2, cols: int, rows: int, ink: Color) -> void:
	var cw = 44.0
	var ch = 32.0
	var wood_dark = Color(0.28, 0.22, 0.18, 0.9)
	var wood_mid = Color(0.38, 0.30, 0.22, 0.9)
	
	for r in range(rows):
		for c in range(cols):
			var cx = pos.x + c * cw - (cols * cw * 0.5)
			var cy = pos.y - r * ch
			# Crate body
			draw_rect(Rect2(cx, cy, cw - 2, ch - 2), ink)
			draw_rect(Rect2(cx + 2, cy + 2, cw - 6, ch - 6), wood_dark)
			# Wood planks
			draw_line(Vector2(cx + 2, cy + ch * 0.5), Vector2(cx + cw - 4, cy + ch * 0.5), ink, 1.5)
			# Stenciled diagonal cross brace
			draw_line(Vector2(cx + 4, cy + 4), Vector2(cx + cw - 6, cy + ch - 6), wood_mid, 2.0)
			draw_line(Vector2(cx + cw - 6, cy + 4), Vector2(cx + 4, cy + ch - 6), wood_mid, 2.0)
