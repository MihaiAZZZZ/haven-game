extends Node2D
class_name CartoonPlatform

enum PlatformStyle { BRASS_CLOCKWORK, WOODEN_DOCK, CRYSTAL_CAVE, CELESTIAL_CLOUD, MILITARY_STEEL }

@export var size: Vector2 = Vector2(180, 28)
@export var style: PlatformStyle = PlatformStyle.BRASS_CLOCKWORK
@export var pixel_size: float = 2.0
@export var ink_color: Color = Color(0.11, 0.08, 0.15, 1.0)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var half_w = size.x * 0.5
	var half_h = size.y * 0.5
	var rect = Rect2(-half_w, -half_h, size.x, size.y)

	var shadow_rect = Rect2(-half_w + 4.0, -half_h + 4.0, size.x, size.y)
	draw_rect(shadow_rect, Color(0.06, 0.04, 0.09, 0.45))

	match style:
		PlatformStyle.BRASS_CLOCKWORK:
			_draw_brass_pixel_slab(rect, half_w, half_h)
		PlatformStyle.WOODEN_DOCK:
			_draw_wood_pixel_slab(rect, half_w, half_h)
		PlatformStyle.CRYSTAL_CAVE:
			_draw_cave_pixel_slab(rect, half_w, half_h)
		PlatformStyle.CELESTIAL_CLOUD:
			_draw_cloud_pixel_slab(rect, half_w, half_h)
		PlatformStyle.MILITARY_STEEL:
			_draw_steel_pixel_slab(rect, half_w, half_h)

func _draw_steel_pixel_slab(rect: Rect2, half_w: float, half_h: float) -> void:
	var p = pixel_size
	draw_rect(rect, Color(0.24, 0.25, 0.29, 1.0))
	draw_rect(Rect2(-half_w, -half_h, size.x, 2.0 * p), Color(0.48, 0.52, 0.58, 1.0))
	draw_rect(Rect2(-half_w, half_h - 2.0 * p, size.x, 2.0 * p), Color(0.12, 0.13, 0.16, 1.0))

	var seg_w = 32.0
	var x = -half_w + seg_w
	while x < half_w - 6.0:
		draw_rect(Rect2(x, -half_h + 2.0 * p, p, size.y - 4.0 * p), ink_color)
		draw_rect(Rect2(x + p, -half_h + 2.0 * p, p, size.y - 4.0 * p), Color(0.38, 0.40, 0.45, 1.0))
		draw_rect(Rect2(x - 8.0, -half_h + 4.0 * p, 2.0 * p, 2.0 * p), ink_color)
		draw_rect(Rect2(x - 8.0, half_h - 6.0 * p, 2.0 * p, 2.0 * p), ink_color)
		x += seg_w

	draw_rect(rect, ink_color, false, 2.0 * p)

func _draw_brass_pixel_slab(rect: Rect2, half_w: float, half_h: float) -> void:
	var p = pixel_size
	draw_rect(rect, Color(0.72, 0.54, 0.22, 1.0))
	draw_rect(Rect2(-half_w, -half_h, size.x, 2.0 * p), Color(0.96, 0.84, 0.45, 1.0))
	draw_rect(Rect2(-half_w, half_h - 2.0 * p, size.x, 2.0 * p), Color(0.44, 0.3, 0.12, 1.0))

	var seg_w = 32.0
	var x = -half_w + seg_w
	while x < half_w - 6.0:
		draw_rect(Rect2(x, -half_h + 2.0 * p, p, size.y - 4.0 * p), ink_color)
		draw_rect(Rect2(x + p, -half_h + 2.0 * p, p, size.y - 4.0 * p), Color(0.85, 0.68, 0.32, 1.0))
		x += seg_w

	_draw_pixel_rivet(Vector2(-half_w + 10.0, 0), p)
	_draw_pixel_rivet(Vector2(half_w - 10.0, 0), p)

	draw_rect(rect, ink_color, false, 2.0 * p)

func _draw_wood_pixel_slab(rect: Rect2, half_w: float, half_h: float) -> void:
	var p = pixel_size
	draw_rect(rect, Color(0.24, 0.35, 0.44, 1.0))
	draw_rect(Rect2(-half_w, -half_h, size.x, 2.0 * p), Color(0.44, 0.6, 0.72, 1.0))
	draw_rect(Rect2(-half_w, half_h - 2.0 * p, size.x, 2.0 * p), Color(0.14, 0.2, 0.28, 1.0))

	var plank_w = 24.0
	var x = -half_w + plank_w
	while x < half_w - 4.0:
		draw_rect(Rect2(x, -half_h + 2.0 * p, p, size.y - 4.0 * p), ink_color)
		draw_rect(Rect2(x + p, -half_h + 2.0 * p, p, size.y - 4.0 * p), Color(0.35, 0.48, 0.58, 1.0))
		draw_rect(Rect2(x - 6.0, -half_h + 4.0 * p, 2.0 * p, 2.0 * p), ink_color)
		x += plank_w

	draw_rect(rect, ink_color, false, 2.0 * p)

func _draw_cave_pixel_slab(rect: Rect2, half_w: float, half_h: float) -> void:
	var p = pixel_size
	draw_rect(rect, Color(0.26, 0.18, 0.3, 1.0))
	draw_rect(Rect2(-half_w, -half_h, size.x, 2.0 * p), Color(0.52, 0.34, 0.62, 1.0))
	draw_rect(Rect2(-half_w, half_h - 2.0 * p, size.x, 2.0 * p), Color(0.14, 0.1, 0.18, 1.0))

	var brick_w = 28.0
	var x = -half_w + 14.0
	while x < half_w - 4.0:
		draw_rect(Rect2(x, -half_h + 2.0 * p, p, size.y - 4.0 * p), ink_color)
		x += brick_w

	var gem_step = size.x / 3.0
	for i in range(2):
		var gx = -half_w + 24.0 + i * gem_step
		draw_rect(Rect2(gx, -half_h + 3.0 * p, 2.0 * p, 2.0 * p), Color(0.4, 0.9, 1.0, 1.0))
		draw_rect(Rect2(gx + p, -half_h + 3.0 * p, p, p), Color.WHITE)

	draw_rect(rect, ink_color, false, 2.0 * p)

func _draw_cloud_pixel_slab(rect: Rect2, half_w: float, half_h: float) -> void:
	var p = pixel_size
	draw_rect(rect, Color(0.92, 0.95, 1.0, 1.0))
	draw_rect(Rect2(-half_w, -half_h, size.x, 3.0 * p), Color.WHITE)
	draw_rect(Rect2(-half_w, half_h - 3.0 * p, size.x, 3.0 * p), Color(0.72, 0.78, 0.9, 1.0))
	draw_rect(rect, ink_color, false, 2.0 * p)

func _draw_pixel_rivet(pos: Vector2, p: float) -> void:
	draw_rect(Rect2(pos.x - p, pos.y - p * 0.5, p, p), ink_color)
	draw_rect(Rect2(pos.x + p, pos.y - p * 0.5, p, p), ink_color)
	draw_rect(Rect2(pos.x, pos.y - p * 1.5, p, p), ink_color)
	draw_rect(Rect2(pos.x, pos.y + p * 0.5, p, p), ink_color)
	draw_rect(Rect2(pos.x, pos.y - p * 0.5, p, p), Color(0.92, 0.78, 0.35, 1.0))
