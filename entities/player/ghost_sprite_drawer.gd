extends Node2D
class_name GhostSpriteDrawer

@export var pixel_scale: float = 2.5
@export var ghost_color: Color = Color(0.98, 0.96, 0.92, 1.0)
@export var ghost_shadow: Color = Color(0.86, 0.82, 0.78, 1.0)
@export var ink_color: Color = Color(0.11, 0.08, 0.15, 1.0)
@export var eye_color: Color = Color(0.11, 0.08, 0.15, 1.0)
@export var blush_color: Color = Color(0.95, 0.55, 0.58, 1.0)

@export var phased_fill: Color = Color(0.85, 0.8, 0.98, 0.75)
@export var phased_shadow: Color = Color(0.72, 0.65, 0.88, 0.7)
@export var phased_ink: Color = Color(0.35, 0.28, 0.52, 0.95)

var _time: float = 0.0
var _blink_timer: float = 2.5
var _is_blinking: bool = false
var _pupil_dir: Vector2i = Vector2i.ZERO

const HEM_FRAMES: Array = [
	[1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0],
	[0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0],
	[0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1],
	[1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1]
]

func _process(delta: float) -> void:
	_time += delta
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_is_blinking = true
		if _blink_timer <= -0.15:
			_is_blinking = false
			_blink_timer = randf_range(2.0, 4.5)

	var parent_ghost = get_parent().get_parent() as GhostPlayer
	if parent_ghost:
		var target_x = 0
		var target_y = 0
		if abs(parent_ghost.velocity.x) > 15.0:
			target_x = 1 if parent_ghost.velocity.x > 0 else -1
		if parent_ghost.velocity.y < -30.0:
			target_y = -1
		elif parent_ghost.velocity.y > 30.0:
			target_y = 1
		_pupil_dir = Vector2i(target_x, target_y)

	queue_redraw()

func _draw() -> void:
	var parent_ghost = get_parent().get_parent() as GhostPlayer
	var is_phased = parent_ghost.is_phased if parent_ghost else false

	var col_fill = phased_fill if is_phased else ghost_color
	var col_shad = phased_shadow if is_phased else ghost_shadow
	var col_ink = phased_ink if is_phased else ink_color

	var p = pixel_scale
	var ox = -8.0 * p
	var oy = -18.0 * p

	var float_step = int(sin(_time * 4.0) * 1.5)
	oy += float_step * p

	var hem_frame_idx = int(fmod(_time * 6.0, 4.0))
	var hem = HEM_FRAMES[hem_frame_idx]

	for y in range(18):
		for x in range(16):
			var cell_col = Color.TRANSPARENT

			if y == 0:
				if x >= 4 and x <= 11:
					cell_col = col_ink
			elif y == 1:
				if x == 2 or x == 3 or x == 12 or x == 13:
					cell_col = col_ink
				elif x >= 4 and x <= 11:
					cell_col = col_fill
			elif y == 2:
				if x == 1 or x == 14:
					cell_col = col_ink
				elif x >= 2 and x <= 13:
					cell_col = col_fill
			elif y >= 3 and y <= 14:
				if x == 0 or x == 15:
					cell_col = col_ink
				elif x >= 1 and x <= 14:
					if (x >= 12 or y >= 13) and not is_phased:
						cell_col = col_shad
					else:
						cell_col = col_fill
			elif y == 15:
				if x == 0 or x == 15:
					cell_col = col_ink
				elif hem[x] == 1:
					cell_col = col_ink
				else:
					cell_col = col_shad if not is_phased else col_fill
			elif y == 16:
				if hem[x] == 1 and x >= 1 and x <= 14:
					cell_col = col_ink

			if cell_col.a > 0.0:
				draw_rect(Rect2(ox + x * p, oy + y * p, p, p), cell_col)

	var eye_y = 5
	var eye_lx = 4
	var eye_rx = 10

	if not _is_blinking:
		_draw_pixel_eye(ox + eye_lx * p, oy + eye_y * p, p, _pupil_dir)
		_draw_pixel_eye(ox + eye_rx * p, oy + eye_y * p, p, _pupil_dir)
	else:
		draw_rect(Rect2(ox + eye_lx * p, oy + (eye_y + 1) * p, 2 * p, p), col_ink)
		draw_rect(Rect2(ox + eye_rx * p, oy + (eye_y + 1) * p, 2 * p, p), col_ink)

	draw_rect(Rect2(ox + 2 * p, oy + 8 * p, 2 * p, p), blush_color)
	draw_rect(Rect2(ox + 12 * p, oy + 8 * p, 2 * p, p), blush_color)

	draw_rect(Rect2(ox + 7 * p, oy + 9 * p, 2 * p, p), col_ink)

	if is_phased:
		for i in range(4):
			var spark_t = fmod(_time * 2.5 + i * 0.7, 1.0)
			var sx = ox + (sin(i * 2.3 + _time * 2.0) * 12.0 + 8.0) * p
			var sy = oy + (14.0 - spark_t * 22.0) * p
			var spark_col = Color(0.9, 0.85, 1.0, 1.0 - spark_t)
			draw_rect(Rect2(sx, sy, p, p), spark_col)
			draw_rect(Rect2(sx - p, sy, p, p), Color(0.6, 0.9, 1.0, (1.0 - spark_t) * 0.6))

func _draw_pixel_eye(px: float, py: float, p: float, pdir: Vector2i) -> void:
	draw_rect(Rect2(px, py, 2 * p, 3 * p), Color.WHITE)
	var pup_x = px + (0 if pdir.x <= 0 else 1) * p
	var pup_y = py + (1 + pdir.y) * p
	draw_rect(Rect2(pup_x, pup_y, p, p), eye_color)
	draw_rect(Rect2(px, py, p, p), Color.WHITE)
