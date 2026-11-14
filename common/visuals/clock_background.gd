extends Node2D
class_name ClockBackground

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var ink = Color(0.12, 0.09, 0.12, 1.0)
	var p = 3.0

	draw_rect(Rect2(0, 0, 1280, 720), Color(0.22, 0.16, 0.14))

	for y in range(0, 720, 48):
		draw_rect(Rect2(0, y, 1280, p), Color(0.18, 0.12, 0.11))
		draw_rect(Rect2(0, y + p, 1280, p), Color(0.26, 0.19, 0.17))

	_draw_pixel_gear(Vector2(260, 240), 150.0, 8, _time * 0.25, Color(0.72, 0.52, 0.24), ink, p)
	_draw_pixel_gear(Vector2(560, 420), 100.0, 6, -_time * 0.35, Color(0.65, 0.46, 0.2), ink, p)
	_draw_pixel_gear(Vector2(160, 560), 80.0, 6, _time * 0.4, Color(0.58, 0.4, 0.18), ink, p)

	var center = Vector2(980, 320)
	var dial_r = 170.0

	_draw_stepped_pixel_circle(center, dial_r + 6.0, ink, p)
	_draw_stepped_pixel_circle(center, dial_r, Color(0.95, 0.92, 0.84), p)
	_draw_stepped_pixel_circle(center, dial_r - 18.0, Color(0.91, 0.87, 0.78), p)

	for i in range(12):
		var a = (float(i) / 12.0) * TAU
		var p1 = center + Vector2(cos(a), sin(a)) * (dial_r - 30.0)
		draw_rect(Rect2(p1.x - p * 1.5, p1.y - p * 1.5, p * 3.0, p * 3.0), ink)

	var h_angle = _time * 0.6
	var m_angle = _time * 2.0
	_draw_pixel_hand_line(center, h_angle, 65.0, 5.0, ink, p)
	_draw_pixel_hand_line(center, m_angle, 105.0, 3.5, ink, p)
	draw_rect(Rect2(center.x - p * 2.0, center.y - p * 2.0, p * 4.0, p * 4.0), Color(0.9, 0.72, 0.3))

	var pend_origin = Vector2(640, 40)
	var pend_angle = sin(_time * 2.2) * 0.3
	var pend_len = 270.0
	var pend_bob = pend_origin + Vector2(sin(pend_angle) * pend_len, cos(pend_angle) * pend_len)

	draw_line(pend_origin, pend_bob, ink, 4.0)
	draw_line(pend_origin, pend_bob, Color(0.78, 0.62, 0.28), 2.0)
	_draw_pixel_diamond(pend_bob, 26.0, ink)
	_draw_pixel_diamond(pend_bob, 22.0, Color(0.88, 0.72, 0.32))
	_draw_pixel_diamond(pend_bob + Vector2(-4, -4), 6.0, Color(0.98, 0.92, 0.65))

func _draw_stepped_pixel_circle(center: Vector2, radius: float, col: Color, p: float) -> void:
	var steps = 16
	var pts = PackedVector2Array()
	for i in range(steps):
		var a = (float(i) / steps) * TAU
		pts.append(center + Vector2(floor(cos(a) * radius / p) * p, floor(sin(a) * radius / p) * p))
	draw_colored_polygon(pts, col)

func _draw_pixel_hand_line(center: Vector2, angle: float, length: float, width: float, col: Color, p: float) -> void:
	var target = center + Vector2(cos(angle), sin(angle)) * length
	var steps = int(length / (p * 2.0))
	for i in range(steps):
		var t = float(i) / steps
		var pos = center.lerp(target, t)
		draw_rect(Rect2(floor(pos.x / p) * p, floor(pos.y / p) * p, p * 2.0, p * 2.0), col)

func _draw_pixel_diamond(pos: Vector2, r: float, col: Color) -> void:
	var pts = PackedVector2Array([
		Vector2(pos.x, pos.y - r),
		Vector2(pos.x + r, pos.y),
		Vector2(pos.x, pos.y + r),
		Vector2(pos.x - r, pos.y)
	])
	draw_colored_polygon(pts, col)

func _draw_pixel_gear(pos: Vector2, radius: float, teeth: int, rot: float, body_col: Color, ink: Color, p: float) -> void:
	for i in range(teeth):
		var a = (float(i) / teeth) * TAU + rot
		var t_pos = pos + Vector2(cos(a), sin(a)) * (radius + 10.0)
		draw_rect(Rect2(t_pos.x - 12.0, t_pos.y - 12.0, 24.0, 24.0), ink)
		draw_rect(Rect2(t_pos.x - 9.0, t_pos.y - 9.0, 18.0, 18.0), body_col)
	_draw_stepped_pixel_circle(pos, radius, ink, p)
	_draw_stepped_pixel_circle(pos, radius - 4.0, body_col, p)
	_draw_stepped_pixel_circle(pos, radius * 0.45, ink, p)
	_draw_stepped_pixel_circle(pos, radius * 0.45 - 3.0, Color(0.22, 0.16, 0.14), p)
