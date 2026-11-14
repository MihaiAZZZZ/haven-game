extends Node2D
class_name OldHouseBackground

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	var ink = Color(0.11, 0.09, 0.15, 1.0)
	var p = 3.0

	draw_rect(Rect2(0, 0, 1280, 720), Color(0.22, 0.21, 0.25))

	for x in range(0, 1280, 64):
		draw_rect(Rect2(x, 0, p, 720), Color(0.17, 0.16, 0.20))
		draw_rect(Rect2(x + p, 0, p, 720), Color(0.26, 0.25, 0.30))

	draw_rect(Rect2(0, 0, 1280, 24), ink)
	draw_rect(Rect2(0, 4, 1280, 16), Color(0.30, 0.28, 0.32))

	var win_pos = Vector2(340, 140)
	draw_rect(Rect2(win_pos.x - 4, win_pos.y - 4, 128, 188), ink)
	draw_rect(Rect2(win_pos.x, win_pos.y, 120, 180), Color(0.12, 0.10, 0.18))
	draw_rect(Rect2(win_pos.x + 4, win_pos.y + 4, 112, 172), Color(0.14, 0.15, 0.24))
	draw_rect(Rect2(win_pos.x + 80, win_pos.y + 24, 16, 16), Color(0.95, 0.92, 0.82))
	draw_rect(Rect2(win_pos.x + 24, win_pos.y + 40, 4, 4), Color(0.85, 0.85, 0.95))
	draw_rect(Rect2(win_pos.x + 55, win_pos.y + 70, 3, 3), Color(0.85, 0.85, 0.95))
	draw_rect(Rect2(win_pos.x + 58, win_pos.y, 4, 180), ink)
	draw_rect(Rect2(win_pos.x, win_pos.y + 90, 120, 4), ink)
	var flicker = sin(_time * 4.0) * 0.05
	draw_rect(Rect2(win_pos.x - 20, win_pos.y + 160, 160, 40), Color(0.95, 0.78, 0.4, 0.12 + flicker))

	_draw_pixel_frame(Vector2(640, 180), Vector2(70, 90), ink, Color(0.35, 0.30, 0.40))
	_draw_pixel_frame(Vector2(840, 190), Vector2(60, 80), ink, Color(0.38, 0.34, 0.38))
	_draw_pixel_frame(Vector2(160, 200), Vector2(60, 74), ink, Color(0.36, 0.32, 0.38))

	var fp_x = 1020
	var fp_y = 480
	draw_rect(Rect2(fp_x - 8, fp_y - 8, 176, 178), ink)
	draw_rect(Rect2(fp_x, fp_y, 160, 170), Color(0.30, 0.28, 0.32))
	draw_rect(Rect2(fp_x + 24, fp_y + 40, 112, 130), ink)
	draw_rect(Rect2(fp_x + 26, fp_y + 42, 108, 126), Color(0.12, 0.08, 0.10))
	var flame_h = 24.0 + sin(_time * 6.0) * 4.0
	draw_rect(Rect2(fp_x + 60, fp_y + 140 - flame_h, 40, flame_h), Color(0.96, 0.55, 0.2))
	draw_rect(Rect2(fp_x + 68, fp_y + 145 - flame_h * 0.7, 24, flame_h * 0.7), Color(1.0, 0.85, 0.35))
	draw_circle(Vector2(fp_x + 80, fp_y + 130), 120.0, Color(0.95, 0.65, 0.25, 0.08 + flicker))

func _draw_pixel_frame(center: Vector2, frame_size: Vector2, ink: Color, backing: Color) -> void:
	var hw = frame_size.x * 0.5
	var hh = frame_size.y * 0.5
	draw_rect(Rect2(center.x - hw - 3, center.y - hh - 3, frame_size.x + 6, frame_size.y + 6), ink)
	draw_rect(Rect2(center.x - hw, center.y - hh, frame_size.x, frame_size.y), Color(0.82, 0.68, 0.35))
	draw_rect(Rect2(center.x - hw + 4, center.y - hh + 4, frame_size.x - 8, frame_size.y - 8), backing)
	draw_rect(Rect2(center.x - 8, center.y - 14, 16, 16), ink)
	draw_rect(Rect2(center.x - 14, center.y + 2, 28, 16), ink)
